/* Copyright (c) 2026, MariaDB plc

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; version 2 of the License.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1335  USA */

#pragma once

/* BACKUP SERVER support for Aria engine. */

#include <sql_backup_interface.h>
#include <handler.h>

/**
   Start of a BACKUP SERVER phase,
   when no aria_backup_step() or aria_backup_end() is pending.
   @param thd     current session
   @param target  backup target
   @param phase   BACKUP_PHASE_START, ...
   @return error code
   @retval 0 on success
*/
int aria_backup_start(THD *thd, const backup_target &target,
                      backup_phase phase) noexcept;

/**
   Process a file that was collected in aria_backup_start().
   @param thd   current session
   @param target  backup target
   @param phase   last phase on which backup_start() was successfully invoked
   @retval 0 on completion
*/
int aria_backup_step(THD *thd, const backup_target &target,
                     backup_phase phase) noexcept;

/**
   Finish a phase, once all calls for the current phase are completed.
   @param thd   current session
   @param target  backup target
   @param phase   current backup phase, or
   one of the special values BACKUP_PHASE_ABORT or BACKUP_PHASE_FINISH
   @return error code
   @retval 0 on success
*/
int aria_backup_end(THD *thd, const backup_target &target,
                    backup_phase phase) noexcept;
