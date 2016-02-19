with BBS.BBB.i2c;
--
-- This package contains constants and routines to communicate with the LMS303DLHC
-- accelerometer and magnetometer on the i2c bus.
--
-- The interface is fairly basic and doesn't use the advanced features of the
-- device.  If you wish a more sophisticated interface, this could provide a
-- useful starting point.
--
package BBS.BBB.i2c.LMS303DLHC is
   --
   -- Addresses for LMS303DLHC - accelerometer and magnetometer
   -- Note that though the accelerometer and magnetometer are on the same
   -- physical chip, they have different addresses on the I2C bus.
   --
   -- Accelerometer
   addr_accel : constant addr7 := 16#19#;
   accel_ctrl1 : constant uint8 := 16#20#;
   accel_ctrl2 : constant uint8 := 16#21#;
   accel_ctrl3 : constant uint8 := 16#22#;
   accel_ctrl4 : constant uint8 := 16#23#;
   --
   fs_2g : constant uint8 := 16#00#; -- Default
   fs_4g : constant uint8 := 16#10#;
   fs_8g : constant uint8 := 16#20#;
   fs_16g : constant uint8 := 16#40#;
   --
   accel_ctrl5 : constant uint8 := 16#24#;
   accel_ctrl6 : constant uint8 := 16#25#;
   accel_ref : constant uint8 := 16#26#;
   accel_status : constant uint8 := 16#27#;
   --
   -- Status bits
   accel_stat_zyxor : constant uint8 := 16#80#;
   accel_stat_zor : constant uint8 := 16#40#;
   accel_stat_yor : constant uint8 := 16#20#;
   accel_stat_xor : constant uint8 := 16#10#;
   accel_stat_zyxda : constant uint8 := 16#08#;
   accel_stat_zda : constant uint8 := 16#04#;
   accel_stat_yda : constant uint8 := 16#02#;
   accel_stat_xda : constant uint8 := 16#01#;
   --
   accel_out_x_h : constant uint8 := 16#28#;
   accel_out_x_l : constant uint8 := 16#29#;
   accel_out_y_h : constant uint8 := 16#2a#;
   accel_out_y_l : constant uint8 := 16#2b#;
   accel_out_z_h : constant uint8 := 16#2c#;
   accel_out_z_l : constant uint8 := 16#2d#;
   accel_fifo_ctrl : constant uint8 := 16#2e#;
   accel_fifo_src : constant uint8 := 16#2f#;
   accel_int1_cfg : constant uint8 := 16#30#;
   accel_int1_src : constant uint8 := 16#31#;
   accel_int1_ths : constant uint8 := 16#32#;
   accel_int1_duration : constant uint8 := 16#33#;
   accel_int2_cfg : constant uint8 := 16#34#;
   accel_int2_src : constant uint8 := 16#35#;
   accel_int2_ths : constant uint8 := 16#36#;
   accel_int2_duration : constant uint8 := 16#37#;
   accel_click_cfg : constant uint8 := 16#38#;
   accel_click_src : constant uint8 := 16#39#;
   accel_click_ths : constant uint8 := 16#3a#;
   accel_time_limit : constant uint8 := 16#3b#;
   accel_time_latency : constant uint8 := 16#3c#;
   accel_time_window : constant uint8 := 16#3d#;
   --
   -- Magnetometer
   addr_mag : constant addr7 := 16#1e#;
   mag_cra : constant uint8 := 16#00#;
   mag_crb : constant uint8 := 16#01#;
   --
   fs_1_3_gauss : constant uint8 := 16#20#;
   fs_1_9_gauss : constant uint8 := 16#40#;
   fs_2_5_gauss : constant uint8 := 16#60#;
   fs_4_0_gauss : constant uint8 := 16#80#;
   fs_4_7_gauss : constant uint8 := 16#a0#;
   fs_5_6_gauss : constant uint8 := 16#c0#;
   fs_8_1_gauss : constant uint8 := 16#e0#;
   --
   mag_mr : constant uint8 := 16#02#;
   mag_out_x_h : constant uint8 := 16#03#;
   mag_out_x_l : constant uint8 := 16#04#;
   mag_out_y_h : constant uint8 := 16#07#; -- note not ascending order
   mag_out_y_l : constant uint8 := 16#08#;
   mag_out_z_h : constant uint8 := 16#05#;
   mag_out_z_l : constant uint8 := 16#06#;
   mag_sr : constant uint8 := 16#09#;
   --
   -- Status bits
   mag_lock : constant uint8 := 16#02#;
   mag_drdy : constant uint8 := 16#01#;
   --
   mag_ira : constant uint8 := 16#0a#;
   mag_irb : constant uint8 := 16#0b#;
   mag_irc : constant uint8 := 16#0c#;
   mag_temp_h : constant uint8 := 16#31#;
   mag_temp_l : constant uint8 := 16#32#;
   --
   -- Define some types
   --
   type accel_g is new float;
   --
   type accelerations is
      record
         x : integer;
         y : integer;
         z : integer;
      end record;
   --
   type accelerations_g is
      record
         x : accel_g;
         y : accel_g;
         z : accel_g;
      end record;
   --
   type gauss is new float;
   --
   type magnetism is
      record
         x : integer;
         y : integer;
         z : integer;
      end record;
   --
   type magnetism_gauss is
      record
         x : gauss;
         y : gauss;
         z : gauss;
      end record;
   --
   -- If you need more temperature types, take a look at the BMP180 package and
   -- copy them.
   --
   type Celsius is new float;
   --
   procedure configure(error : out integer);
   procedure configure(accel_fs : uint8; mag_fs: uint8; error : out integer);
   --
   function get_acceleration_x(error : out integer) return integer;
   function get_acceleration_y(error : out integer) return integer;
   function get_acceleration_z(error : out integer) return integer;
   function get_accelerations(error : out integer) return accelerations;
   --
   function get_acceleration_x(error : out integer) return accel_g;
   function get_acceleration_y(error : out integer) return accel_g;
   function get_acceleration_z(error : out integer) return accel_g;
   function get_accelerations(error : out integer) return accelerations_g;
   --
   function get_accel_status(error : out integer) return uint8;
   function accel_data_ready(error : out integer) return boolean;
   --
   function get_temperature(error : out integer) return integer;
   function get_temperature(error : out integer) return float;
   function get_temperature(error : out integer) return Celsius;
   --
   function get_magnet_x(error : out integer) return integer;
   function get_magnet_y(error : out integer) return integer;
   function get_magnet_z(error : out integer) return integer;
   function get_magnetism(error : out integer) return magnetism;
   --
   function get_magnet_x(error : out integer) return gauss;
   function get_magnet_y(error : out integer) return gauss;
   function get_magnet_z(error : out integer) return gauss;
   function get_magnetism(error : out integer) return magnetism_gauss;
   --
   function get_mag_status(error : out integer) return uint8;
   function mag_data_ready(error : out integer) return boolean;

private
   buff : aliased buffer;
   --
   -- The temperature offset is emperically determined and seems to work for my
   -- application.  You may want to check the values that you get from the
   -- temperature sensor and compare them with a calibrated thermometer to
   -- determine your own value.
   --
   temperature_offset : constant integer := 136;
   --
   accel_scale : float := 2.0 / 32768.0;
   mag_scale : float := 1.3 / 2048.0;
end;