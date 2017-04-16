/*
 * linker.lds
 *
 * 2012 (c) Daniel Sangorrin <daniel.sangorrin@gmail.com>
 *
 * Linker script for adding a wrapper to a Linux kernel. The wrapper
 * contains code required for booting Linux on ARM (see the file
 * linux/Documentation/arm/Booting for more details).
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 *
 */
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
TARGET(binary)

INPUT(./Image)
INPUT(./boot.o)

SECTIONS
{
    .text : {
        __boot_start = . ;
        boot.o
    }

    . = __boot_start + 0x8000;
    kernel = .;
    .kernel : { ./Image }

    .data : { *(.data) }
    .bss : { *(.bss) }
}
