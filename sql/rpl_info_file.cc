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

#include "mariadb.h"
#include "rpl_info_file.h"
#include <mysqld_error.h> // Error numbers
#include <m_string.h>   // strmake, int10_to_str, ll2str


namespace Int_IO_CACHE
{
  bool uint_from_chars(IO_CACHE *file, ulonglong max_value, ulonglong *result)
  {
    int error;
    /* +1 for the trailing '\0' that my_b_gets() appends. */
    char buf[LONGLONG_BUFFER_SIZE + 1];
    size_t length= my_b_gets(file, buf, sizeof(buf));
    if (!length)
      return true;
    char *end= buf + length;
    longlong val= my_strtoll10(buf, &end, &error);
    if (error != 0 || *end != '\n' || (ulonglong) val > max_value)
      return true;
    *result= (ulonglong) val;
    return false;
  }


  void uint_to_chars(IO_CACHE *file, ulonglong value)
  {
    char buf[LONGLONG_BUFFER_SIZE];
    char *end= ll2str((longlong) value, buf, 10, 0);
    my_b_write(file, (const uchar *) buf, end - buf);
  }
}


bool Info_file::Uint_value::load_from(IO_CACHE *file)
{
  ulonglong tmp;
  if (Int_IO_CACHE::uint_from_chars(file, UINT_MAX32, &tmp))
  {
    set_default();
    return true;
  }
  value= (uint) tmp;
  has_value= true;
  return false;
}


void Info_file::Uint_value::save_to(IO_CACHE *file)
{
  Int_IO_CACHE::uint_to_chars(file, value);
}


bool Info_file::Ulonglong_value::load_from(IO_CACHE *file)
{
  if (Int_IO_CACHE::uint_from_chars(file, ULONGLONG_MAX, &value))
  {
    set_default();
    return true;
  }
  has_value= true;
  return false;
}


void Info_file::Ulonglong_value::save_to(IO_CACHE *file)
{
  Int_IO_CACHE::uint_to_chars(file, value);
}


void Info_file::String_value::operator=(const char *other)
{
  strmake(buf, other, buf_size - 1);
  has_value= true;
}


bool Info_file::String_value::load_from(IO_CACHE *file)
{
  size_t length= my_b_gets(file, buf, buf_size);
  if (!length)
  {
    set_default();
    return true;
  }
  /* If we stopped on a newline, kill it. */
  char *last_char= buf + length - 1;
  if (*last_char == '\n')
  {
    *last_char= '\0';
    has_value= true;
    return false;
  }
  /* Consume the lost line break, or error if the line overflowed. */
  if (my_b_get(file) != '\n')
  {
    set_default();
    return true;
  }
  has_value= true;
  return false;
}


void Info_file::String_value::save_to(IO_CACHE *file)
{
  const char *p= *this;
  my_b_write(file, (const uchar *) p, strlen(p));
}


bool Info_file::load_from_file(Value *const *values, size_t size,
                               size_t default_line_count)
{
  long val;
  /*
    The first row is temporarily stored in the first value. If it is a
    line count and not a log name (new format), the second row will
    overwrite it.
  */
  String_value &line1= dynamic_cast<String_value &>(*values[0]);
  if (line1.load_from(&file))
  {
    my_printf_error(ER_WRONG_VALUE, "Wrong data at start of master info file",
                    MYF(ME_FATAL | ME_ERROR_LOG));
    return true;
  }
  char *end= str2int(line1.buf, 10, 0, INT32_MAX, &val);
  /*
    If this first line was not a number - the line count, then it was
    the first value for real, so the for loop should skip over it.
  */
  size_t i= !end || *end != '\0';
  size_t line_count= i ? default_line_count : (size_t) val;
  for (; i < line_count; ++i)
  {
    int chr;
    if (i < size)
    {
      Value *value= values[i];
      if (value)
      {
        my_off_t filepos= my_b_tell(&file);
        if (value->load_from(&file))
        {
          if (!(reinit_io_cache(&file, READ_CACHE, filepos, 0, 0)))
          {
            char buf[160];
            buf[0]= 0;
            size_t length= my_b_gets(&file, buf, sizeof(buf));
            /* Strip the trailing '\n' that my_b_gets() includes. */
            if (length && buf[length - 1] == '\n')
              buf[length - 1]= '\0';
            my_error(ER_WRONG_VALUE, MYF(ME_FATAL | ME_ERROR_LOG),
                     value->variable_name, buf);
          }
          return true;
        }
        continue;
      }
    }
    /*
      Count and discard unrecognized lines. This is especially to prepare
      for Master_info_file for MariaDB 10.0+, which reserves a bunch of
      lines before its unique key=value section to accomodate any future
      line-based (old-style) additions in MySQL.
    */
    while ((chr= my_b_get(&file)) != '\n')
      if (chr == my_b_EOF)
      {
        my_printf_error(ER_WRONG_VALUE, "Garbage at end of file",
                        MYF(ME_FATAL));
        return true;
      }
  }
  return false;
}


void Info_file::save_to_file(Value *const *values, size_t size,
                             size_t total_line_count)
{
  DBUG_ASSERT(total_line_count > size);
  my_b_seek(&file, 0);
  /*
    If the new contents take less space than the previous file contents,
    we may leave trailing garbage. The garbage does not matter thanks
    to the effective-line count on the first line of the file.
  */
  Int_IO_CACHE::uint_to_chars(&file, total_line_count);
  my_b_write_byte(&file, '\n');
  for (Value *const *value= values, * const *end= value + size;
       value < end;
       value++)
  {
    if (*value)
      (*value)->save_to(&file);
    my_b_write_byte(&file, '\n');
  }
  /* Pad additional reserved lines. */
  for (; total_line_count > size; --total_line_count)
    my_b_write_byte(&file, '\n');
}
