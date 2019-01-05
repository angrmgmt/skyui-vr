class gfx.managers.InputDelegate extends gfx.events.EventDispatcher
{
   var _bEnableControlFixup = false;
   var _acceptKeycode = -1;
   var isGamepad = false;
   function InputDelegate()
   {
      super();
      Key.addListener(this);
      this._keyRepeatSuppressLookup = {};
      this._keyRepeatStateLookup = {};
   }
   static function __get__instance()
   {
      if(gfx.managers.InputDelegate._instance == null)
      {
         gfx.managers.InputDelegate._instance = new gfx.managers.InputDelegate();
      }
      return gfx.managers.InputDelegate._instance;
   }
   function Reset()
   {
      this._keyRepeatStateLookup = {};
   }
   function enableControlFixup(a_bEnabled)
   {
      if(a_bEnabled)
      {
         this._acceptKeycode = skyui.util.GlobalFunctions.getMappedKey("Accept",skyui.defines.Input.CONTEXT_MENUMODE,this.isGamepad);
      }
      this._bEnableControlFixup = a_bEnabled;
   }
   function setKeyRepeat(a_code, a_value, a_controllerIdx)
   {
      var _loc2_ = this.getKeyRepeatSuppress(a_controllerIdx);
      _loc2_[a_code] = !a_value;
   }
   function readInput(type, code, scope, callBack)
   {
      return null;
   }
   function onKeyDown(a_controllerIdx)
   {
      var _loc2_ = Key.getCode(a_controllerIdx);
      var _loc4_ = this.getKeyRepeatState(a_controllerIdx);
      if(!_loc4_[_loc2_])
      {
         this.handleKeyPress("keyDown",_loc2_,a_controllerIdx,skse.GetLastControl(true),skse.GetLastKeycode(true));
         _loc4_[_loc2_] = true;
      }
      else
      {
         var _loc5_ = this.getKeyRepeatSuppress(a_controllerIdx);
         if(!_loc5_[_loc2_])
         {
            this.handleKeyPress("keyHold",_loc2_,a_controllerIdx,skse.GetLastControl(true),skse.GetLastKeycode(true));
         }
      }
   }
   function onKeyUp(a_controllerIdx)
   {
      var _loc2_ = Key.getCode(a_controllerIdx);
      var _loc4_ = this.getKeyRepeatState(a_controllerIdx);
      _loc4_[_loc2_] = false;
      this.handleKeyPress("keyUp",_loc2_,a_controllerIdx,skse.GetLastControl(false),skse.GetLastKeycode(false));
   }
   function handleKeyPress(a_type, a_code, a_controllerIdx, a_control, a_skseKeycode)
   {
      var _loc2_ = this.inputToNav(a_code);
      if(_loc2_ != null)
      {
         switch(_loc2_)
         {
            case gfx.ui.NavigationCode.UP:
            case gfx.ui.NavigationCode.DOWN:
            case gfx.ui.NavigationCode.LEFT:
            case gfx.ui.NavigationCode.RIGHT:
               a_control = null;
               a_skseKeycode = null;
         }
      }
      else if(this._bEnableControlFixup)
      {
         if(a_skseKeycode == this._acceptKeycode)
         {
            _loc2_ = gfx.ui.NavigationCode.ENTER;
         }
      }
      var _loc4_ = new gfx.ui.InputDetails("key",a_code,a_type,_loc2_,a_controllerIdx,a_control,a_skseKeycode);
      this.dispatchEvent({type:"input",details:_loc4_});
   }
   function getKeyRepeatState(a_controllerIdx)
   {
      var _loc2_ = this._keyRepeatStateLookup[a_controllerIdx];
      if(!_loc2_)
      {
         _loc2_ = new Object();
         this._keyRepeatStateLookup[a_controllerIdx] = _loc2_;
      }
      return _loc2_;
   }
   function getKeyRepeatSuppress(a_controllerIdx)
   {
      var _loc2_ = this._keyRepeatSuppressLookup[a_controllerIdx];
      if(!_loc2_)
      {
         _loc2_ = new Object();
         this._keyRepeatSuppressLookup[a_controllerIdx] = _loc2_;
      }
      return _loc2_;
   }
   function inputToNav(a_code)
   {
      switch(a_code)
      {
         case 38:
            return gfx.ui.NavigationCode.UP;
         case 40:
            return gfx.ui.NavigationCode.DOWN;
         case 37:
            return gfx.ui.NavigationCode.LEFT;
         case 39:
            return gfx.ui.NavigationCode.RIGHT;
         case 13:
            return gfx.ui.NavigationCode.ENTER;
         case 8:
            return gfx.ui.NavigationCode.BACK;
         case 9:
            return !Key.isDown(16)?gfx.ui.NavigationCode.TAB:gfx.ui.NavigationCode.SHIFT_TAB;
         case 36:
            return gfx.ui.NavigationCode.HOME;
         case 35:
            return gfx.ui.NavigationCode.END;
         case 34:
            return gfx.ui.NavigationCode.PAGE_DOWN;
         case 33:
            return gfx.ui.NavigationCode.PAGE_UP;
         case 27:
            return gfx.ui.NavigationCode.ESCAPE;
         case 96:
            return gfx.ui.NavigationCode.GAMEPAD_A;
         case 97:
            return gfx.ui.NavigationCode.GAMEPAD_B;
         case 98:
            return gfx.ui.NavigationCode.GAMEPAD_X;
         case 99:
            return gfx.ui.NavigationCode.GAMEPAD_Y;
         case 100:
            return gfx.ui.NavigationCode.GAMEPAD_L1;
         case 101:
            return gfx.ui.NavigationCode.GAMEPAD_L2;
         case 102:
            return gfx.ui.NavigationCode.GAMEPAD_L3;
         case 103:
            return gfx.ui.NavigationCode.GAMEPAD_R1;
         case 104:
            return gfx.ui.NavigationCode.GAMEPAD_R2;
         case 105:
            return gfx.ui.NavigationCode.GAMEPAD_R3;
         case 106:
            return gfx.ui.NavigationCode.GAMEPAD_START;
         case 107:
            return gfx.ui.NavigationCode.GAMEPAD_BACK;
         default:
            return null;
      }
   }
}
