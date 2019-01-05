class skyui.components.list.TabularList extends skyui.components.list.ScrollingList
{
   var _previousColumnKey = -1;
   var _nextColumnKey = -1;
   var _sortOrderKey = -1;
   var _columnOpRequested = 0;
   function TabularList()
   {
      super();
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
   }
   function __get__layout()
   {
      return this._layout;
   }
   function __set__layout(a_layout)
   {
      if(this._layout)
      {
         this._layout.removeEventListener("layoutChange",this,"onLayoutChange");
      }
      this._layout = a_layout;
      this._layout.addEventListener("layoutChange",this,"onLayoutChange");
      if(this.header)
      {
         this.header.__set__layout(a_layout);
      }
      return this.__get__layout();
   }
   function handleInput(details, pathToFocus)
   {
      if(!this.disableInput && this._platform != 0)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(Shared.GlobalFunc.IsKeyPressed(details) && (details.navEquivalent == gfx.ui.NavigationCode.UP && (this.__get__selectedIndex() == -1 || this.getSelectedListEnumIndex() == 0)))
            {
               var _loc4_ = 250;
               if(this._platform == Shared.Platforms.CONTROLLER_OCULUS)
               {
                  _loc4_ = 400;
               }
               if(this._columnOpRequested == 0)
               {
                  var _this = this;
                  setTimeout(function()
                  {
                     if(_this._columnOpRequested == 1)
                     {
                        _this.layout.nextColumn();
                     }
                     else
                     {
                        _this.layout.nextActiveColumnState();
                     }
                     _this._columnOpRequested = 0;
                  }
                  ,_loc4_);
               }
               this._columnOpRequested = this._columnOpRequested + 1;
               return true;
            }
         }
      }
      if(super.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(!this.disableInput && this._platform != 0)
      {
         if(Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(details.skseKeycode == this._previousColumnKey)
            {
               this._layout.selectColumn(this._layout.__get__activeColumnIndex() - 1);
               return true;
            }
            if(details.skseKeycode == this._nextColumnKey)
            {
               this._layout.selectColumn(this._layout.__get__activeColumnIndex() + 1);
               return true;
            }
            if(details.skseKeycode == this._sortOrderKey)
            {
               this._layout.selectColumn(this._layout.__get__activeColumnIndex());
               return true;
            }
         }
      }
      return false;
   }
   function onConfigLoad(event)
   {
      var _loc2_ = event.config;
      if(this._platform != 0)
      {
         this._previousColumnKey = _loc2_.Input.controls.gamepad.prevColumn;
         this._nextColumnKey = _loc2_.Input.controls.gamepad.nextColumn;
         this._sortOrderKey = _loc2_.Input.controls.gamepad.sortOrder;
      }
   }
   function onLayoutChange(event)
   {
      this.entryHeight = this._layout.entryHeight;
      this.header._x = this.leftBorder;
      this._maxListIndex = Math.floor(this._listHeight / this.entryHeight + 0.05);
      if(this._layout.__get__sortAttributes() && this._layout.__get__sortOptions())
      {
         this.dispatchEvent({type:"sortChange",attributes:this._layout.__get__sortAttributes(),options:this._layout.__get__sortOptions()});
      }
      this.requestUpdate();
   }
}
