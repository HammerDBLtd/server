/*
  Copyright (c) 2025 MariaDB

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; version 2 of the License.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along
  with this program; if not, write to the Free Software Foundation, Inc.,
  51 Franklin St, Fifth Floor, Boston, MA 02110-1335 USA.
*/

#ifndef RPL_INFO_FILE_H
#define RPL_INFO_FILE_H

#include <cstdint>    // uintN_t
#include <functional> // Info_file::each_line()
#include <my_sys.h>   // IO_CACHE, FN_REFLEN, ...


/** Helpers for reading and writing integers to and from @ref IO_CACHE
  TODO: Other components, if you find these useful,
    feel free to move these out of this Replication module.
*/
namespace Int_IO_CACHE
{
  /** Number of fully-utilized decimal digits plus
    * the partially-utilized digit (e.g., the 2's place in "2147483647")
    * The sign, if signed (:
  */
  template<typename I> static constexpr size_t BUF_SIZE=
    std::numeric_limits<I>::digits10 + 1 + std::numeric_limits<I>::is_signed;

  /**
    @ref IO_CACHE (reading one line with the `\n`) version of std::from_chars()
    @tparam I integer type
    @return `false` if the line has parsed successfully or `true` if error
  */
  template<typename I> static bool from_chars(IO_CACHE *file, I &value)
  {
    int error;
    /**
      +2 for the terminating `\n\0`
      (They are ignored, but my_b_gets() includes them.)
    */
    char buf[BUF_SIZE<I> + 2];
    /// includes the `\n` but excludes the `\0`
    size_t length= my_b_gets(file, buf, sizeof(buf));
    if (!length) // EOF
      return true;
    char *end= &(buf[length]);
    longlong val= my_strtoll10(buf, &end, &error);
    switch (error) {
    case -1:
      if (!std::numeric_limits<I>::is_signed)
        return true;
      [[fallthrough]];
    case 0:
      /*TODO
        This upper range check is not needed when using type-
        specific variants of a safe string-to-integer converter
        (e.g., std::from_chars() when all platforms support it).
      */
      if (*end == '\n' && value <= std::numeric_limits<I>::max())
      {
        value= static_cast<I>(val);
        return false;
      }
      [[fallthrough]];
    default:
      return true;
    }
  }
  /**
    Convenience overload of from_chars(IO_CACHE *, I &) for `operator=` types
    @tparam I inner integer type
    @tparam T wrapper type
  */
  template<typename I, class T> static bool from_chars(IO_CACHE *file, T *self)
  {
    I value;
    if (from_chars(file, value))
      return true;
    (*self)= value;
    return false;
  }

  /**
    @ref IO_CACHE (writing *without* a `\n`) version of std::to_chars()
    @tparam I (inner) integer type
  */
  template<typename I> static void to_chars(IO_CACHE *file, I value)
  {
    char buf[BUF_SIZE<I>];
    /*TODO:
      * my_b_printf() needs updates and so doesn't
        support `long long`s at the moment.
      * We can avoid format parsing by expanding
        int10_to_str() if not supporting std::to_chars().
    */
    int len= std::numeric_limits<I>::is_signed ?
      snprintf(buf, BUF_SIZE<I>, "%lld", static_cast<long long>(value)) :
      snprintf(buf, BUF_SIZE<I>, "%llu", static_cast<unsigned long long>(value))
    ;
    DBUG_ASSERT(len > 0);
    my_b_write(file, reinterpret_cast<const uchar *>(buf), len);
  }
};


/**
  This common superclass of @ref Master_info_file and
  @ref Relay_log_info_file provides them common code for saving
  and loading values in their MySQL line-based sections.
  As only the @ref Master_info_file has a MariaDB `key=value`
  section with a mix of explicit and `DEFAULT`-able values,
  code for those are in @ref Master_info_file instead.

  Each value is an instance of an implementation of the
  @ref Info_file::Persistent interface. For convenience, they also have
  assignment and implicit conversion operators for their underlying types.

  C++ templates enables code reuse for those implementation structs, but
  templates are not suitable for the conventional header/implementation split.
  Thus, this and derived files are header-only units (methods are `inline`).
  Other files may include these files directly.
  [C++20 modules](https://en.cppreference.com/w/cpp/language/modules.html)
  can supercede the header-only design as well as headers' `#include` guards.
*/
struct Info_file
{
  IO_CACHE file;


  /// Persistence interface for an unspecified item
  struct Persistent
  {
    virtual ~Persistent()= default;
    // for save_to_file()
    virtual bool is_default() { return false; }
    /// @return `true` if the item is mandatory and couldn't provide a default
    virtual bool set_default() { return true; }
    /** set the value by reading a line from the IO and consume the `\n`
      @return `false` if the line has parsed successfully or `true` if error
      @post is_default() is `false`
    */
    virtual bool load_from(IO_CACHE *file)= 0;
    /** write the *effective* value to the IO **without** a `\n`
      (The caller will separately determine how
      to represent using the default value.)
    */
    virtual void save_to(IO_CACHE *file)= 0;
  };

  /** Integer Value
    @tparam I signed or unsigned integer type
    @see Master_info_file::Optional_int_value
      version with `DEFAULT` (not a subclass)
  */
  template<typename I> struct Int_value: Persistent
  {
    I value;
    operator I() { return value; }
    auto &operator=(I value)
    {
      this->value= value;
      return *this;
    }
    virtual bool load_from(IO_CACHE *file) override
    { return Int_IO_CACHE::from_chars(file, value); }
    virtual void save_to(IO_CACHE *file) override
    { return Int_IO_CACHE::to_chars(file, value); }
  };

  /// Null-Terminated String (usually file name) Value
  template<size_t size= FN_REFLEN> struct String_value: Persistent
  {
    char buf[size];
    /**
      Reads should consider this an immutable '\0'-terminated string (especially
      with @ref Optional_path_value where a `DEFAULT` may substitute the value).
      Writes may prefers to directly address the underlying @ref buf.
    */
    virtual operator const char *() { return buf; }
    /// @param other non-`nullptr` `\0`-terminated string
    auto &operator=(const char *other)
    {
      strmake(buf, other, size-1);
      return *this;
    }
    virtual bool load_from(IO_CACHE *file) override
    {
      size_t length= my_b_gets(file, buf, size);
      if (!length) // EOF
        return true;
      /// If we stopped on a newline, kill it.
      char &last_char= buf[length-1];
      if (last_char == '\n')
      {
        last_char= '\0';
        return false;
      }
      /*
        Consume the lost line break,
        or error if the line overflows the @ref buf.
      */
      return my_b_get(file) != '\n';
    }
    virtual void save_to(IO_CACHE *file) override
    {
      const char *buf= *this;
      my_b_write(file, reinterpret_cast<const uchar *>(buf), strlen(buf));
    }
  };

protected:
  struct: Persistent
  {
    /// Seek forward one line
    bool load_from(IO_CACHE *file) override
    {
      for (int c;;)
        switch (c= my_b_get(file)) {
        case my_b_EOF:
          return true; // EOF before line end
        case '\n':
          return false;
        }
    }
    void save_to(IO_CACHE *file) override {} ///< No-op
  } PLACEHOLDER;

  /**
    The number of lines save_to_file() should describe the file as
    on the first line of the file, including the line count line.
    If this is larger than the number of lines in the list iterated
    by each_line(), then it will suffix the file with empty lines
    until the line count (including the line count line) is this many.
    This reservation provides compatibility with MySQL,
    who has added more old-style lines while MariaDB innovated.
  */
  virtual uint32_t mysql_line_count_to_save()= 0;

  template<class E= Persistent>
  using Each_callback= const std::function<bool (E &)> &&;
  /**
    Call `callback` with each value in the MySQL line-based section,
    stop early if a call returns `true`
    @note This should not need to allocate memory.
    @return `true` if the for-each stops early, or `false` if all completed
    @see load_from_file()
    @see save_to_file()
  */
  virtual bool each_line(Each_callback<> callback)= 0;

public:
  virtual ~Info_file()= default;

  virtual bool load_from_file()
  {
    Int_value<uint32_t> line_count;
    if (line_count.load_from(&file) || !line_count.value--)
      return true;
    bool aborted= each_line([file= &file, &line_count] (Persistent &value)
    {
      if (!line_count || value.load_from(file)) // condition in `for`
        return true;
      --line_count.value; // decrement in `for`
      return false;
    });
    if (!line_count)
      return false; // Leave any remaining lines as constructed
    if (aborted) // interrupted mid-file
      return true;
    /*
      Count and discard unrecognized lines.
      This is especially to prepare for @ref Master_info_file for MariaDB 10.0+,
      which reserves a bunch of lines before its unique `key=value` section
      to accomodate any future line-based (old-style) additions in MySQL.
      (This will make moving from MariaDB to MySQL easier by not
      requiring MySQL to recognize MariaDB `key=value` lines.)
    */
    while (line_count.value--)
      PLACEHOLDER.load_from(&file);
    return false;
  }

  virtual void save_to_file()
  {
    Int_value<uint32_t> line_count;
    my_b_seek(&file, 0);
    line_count= mysql_line_count_to_save();
    DBUG_ASSERT(line_count);
    /*
      If the new contents take less space than the previous file contents,
      then this code would write the file with unerased trailing garbage lines.
      But these garbage don't matter thanks to the number
      of effective lines in the first line of the file.
    */
    line_count.save_to(&file);
    /*
      Both this and the loop after it decrement for and close
      the previous line before writing the current line.
    */
    each_line([file= &file, &line_count] (Persistent &value)
    {
      my_b_write_byte(file, '\n');
      line_count.value--;
      DBUG_ASSERT(line_count);
      value.save_to(file);
      return false;
    });
    // Pad additional reserved lines (`line_count..0`)
    while (line_count.value--)
      my_b_write_byte(&file, '\n');
  }
};

#endif
