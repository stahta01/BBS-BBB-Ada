with Ada.Text_IO;
with Ada.Long_Integer_Text_IO;
with Ada.Strings.Fixed;
with Interfaces.C;
with BBS.BBB;
--
--   The Linux i2c driver does not seem to be designed to work well using file
-- read and write calls.  Much of it is based on ioctl calls.  Thus we have to
-- define a bunch of constants and bindings to the C library.  It may be easier
-- if one could just access the device registers for the i2c controller and use
-- it that way.
--
-- Note that this package is not thread safe.  However, you should not be calling
-- the i2c interface from multiple threads anyway.  It also probably only works
-- on one of the i2c interfaces at a time.  These restrictions may be eased in
-- the future.  Right now, the goal is to get the interface to work at all.
--
package BBS.BBB.i2c is
   --
   --
   -- buffer to use for reading and writing from i2c bus.  In most cases, only
   -- a few bytes are needed.  This should be quite adequate.
   --
   type buffer is array(0 .. 127) of uint8;
   type buff_ptr is access all buffer;
   pragma Convention(C, buff_ptr);
   --
   -- Now define routines to actually use the interface.
   --
   -- This procedure configures the pins for i2c-1.  Pins P9-24 and P9-26.
   --
   procedure configure(i2c_file : string);
   --
   -- Routines to read and write data on the i2c bus
   --
   procedure write(addr : addr7; reg : uint8; data : uint8; error : out integer);
   function read(addr : addr7; reg : uint8; error : out integer) return uint8;
   function read(addr : addr7; reg : uint8; error : out integer) return uint16;
   procedure read(addr : addr7; reg : uint8; buff : buff_ptr;
                  size : uint16; error : out integer);

private
   --
   -- The rest of the stuff is private to hid the ugliness required to be
   -- compatible with C data structurs and pointers.
   --
   -- First, declare some bindings to the C library.
   --
   -- Since the basic C file and ioctl calls use a file descriptor, define a
   -- type for it and declare bindings for the C open, read, and write functions.
   --
   type file_id is new interfaces.C.int;
   type mode_t is new integer;
   --
   -- The range is used on size_t so that it is forced to be within the size of
   -- buffer.
   --
   type size_t is new long_integer
   range long_integer(buffer'First) .. long_integer(buffer'Last);
   subtype ssize_t is size_t;
   --
   -- File flags for opening a file read/write.  This is the only one used here
   -- so don't bother to define others.
   --
   O_RDWR : integer := 16#02#;
   --
   function C_open(name : string; flags : integer; mode : mode_t := 8#666#) return file_id;
   pragma import(C, C_open, "open");
   --
   function C_close(file : file_id) return integer;
   pragma import(C, C_close, "close");
   --
   function C_read(file : file_id; buff : in out buffer; length : size_t) return ssize_t;
   pragma import(C, C_read, "read");
   --
   function C_write(file : file_id; buff : in out buffer; length : size_t) return ssize_t;
   pragma import(C, C_write, "write");
   --
   -- Some of the interface actions need to be done using C ioctl calls.  Since
   -- the parameters of the ioctl call depend on the command given an Ada
   -- definition needs to be provided for each variant.
   --
   -- Define structures for ioctl i2c messages.
   --
   type i2c_msg is
      record
         addr : uint16;
         flags : uint16;
         len : uint16;
         buff : buff_ptr;
      end record;
   --
   type i2c_msg_arr is array (0 .. 1) of i2c_msg;
   pragma Convention(C, i2c_msg_arr);
   type i2c_msg_ptr is access all i2c_msg_arr;
   pragma Convention(C, i2c_msg_ptr);
   type i2c_rdwr_ioctl_data is
      record
         messages : i2c_msg_ptr;
         nmsgs : integer;
      end record;
   --
   -- ioctl command numbers taken from /usr/include/linux/i2c_dev.h
   --
   i2c_slave : Interfaces.C.unsigned_long := 16#0703#;
   i2c_slave_force : Interfaces.C.unsigned_long := 16#0706#;
   i2c_tenbit : Interfaces.C.unsigned_long := 16#0704#; -- Apparently broken
   i2c_funcs : Interfaces.C.unsigned_long := 16#0705#;
   i2c_rdwr : Interfaces.C.unsigned_long := 16#0707#;
   i2c_pec : Interfaces.C.unsigned_long := 16#0708#;
   i2c_smbus : Interfaces.C.unsigned_long := 16#0720#;
   --
   -- Since C supports variadic argument lists and Ada doesn't, define different
   -- Ada functions all pointing to ioctl to cover the cases that are used.
   --
   -- basic_ioctl supports the following commands:
   --  i2c_slave
   --  i2c_slave_force
   --  i2c_tenbit (listed as not supported in Linux documentation)
   --  i2c_pec
   --
   function basic_ioctl(f_id : file_id; command : Interfaces.C.unsigned_long;
                         options : Interfaces.C.long) return Interfaces.C.int;
   pragma Import(C, basic_ioctl, "ioctl");
   --
   -- funcs_ioctl supports the i2c_funcs command.
   --
   function funcs_ioctl(f_id : file_id; command : Interfaces.C.unsigned_long;
                         value : out Interfaces.C.long) return Interfaces.C.int;
   pragma Import(C, funcs_ioctl, "ioctl");
   --
   -- rdwr_ioctl supports the i2c_rdwr command.
   --
   function rdwr_ioctl(f_id : file_id; command : Interfaces.C.unsigned_long;
                       value : in out i2c_rdwr_ioctl_data) return Interfaces.C.int;
   pragma Import(C, rdwr_ioctl, "ioctl");
   --
   -- Now some C functions for getting errno and error messages
   --
   function get_errno return integer;
   pragma Import(C, get_errno, "get_errno");
   --
   procedure reset_errno;
   pragma Import(C, reset_errno, "reset_errno");
   --
   type err_msg is new string(1 .. 255);
   type err_msg_ptr is access err_msg;
   --
   procedure perror(msg : string);
   pragma Import(C, perror, "perror");
   --
   function strerror(err_num : integer) return err_msg_ptr;
   pragma Import(C, strerror, "strerror");
   --
   function cvt_cstr_adastr(str_ptr : err_msg_ptr) return string;
   --
   SCL_Ctrl : constant string := "/sys/devices/platform/ocp/ocp:P9_24_pinmux/state";
   SDA_Ctrl : constant string := "/sys/devices/platform/ocp/ocp:P9_26_pinmux/state";
   i2c_fd : file_id;
   --
   -- Buffer and message variables
   --
   buff1 : aliased buffer;
   buff2 : aliased buffer;
   msg : aliased i2c_msg_arr;
   ioctl_msg : i2c_rdwr_ioctl_data;

end;