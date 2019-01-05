class mx.transitions.easing.None
{
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = mx.transitions.easing.None.SKYUI_VERSION_MAJOR + "." + mx.transitions.easing.None.SKYUI_VERSION_MINOR + " SE";
   function None()
   {
   }
   static function easeNone(t, b, c, d)
   {
      return c * t / d + b;
   }
   static function easeIn(t, b, c, d)
   {
      return c * t / d + b;
   }
   static function easeOut(t, b, c, d)
   {
      return c * t / d + b;
   }
   static function easeInOut(t, b, c, d)
   {
      return c * t / d + b;
   }
}
