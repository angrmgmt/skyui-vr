class Shared.BSScrollingList extends MovieClip
{
   static var TEXT_OPTION_NONE = 0;
   static var TEXT_OPTION_SHRINK_TO_FIT = 1;
   static var TEXT_OPTION_MULTILINE = 2;
   function BSScrollingList()
   {
      super();
      this.EntriesA = new Array();
      this.bDisableSelection = false;
      this.bDisableInput = false;
      this.bMouseDrivenNav = false;
      gfx.events.EventDispatcher.initialize(this);
      Mouse.addListener(this);
      this.iSelectedIndex = -1;
      this.iScrollPosition = 0;
      this.iMaxScrollPosition = 0;
      this.iListItemsShown = 0;
      this.iPlatform = 1;
      this.fListHeight = this.border._height;
      this.ListScrollbar = this.scrollbar;
      this.iMaxItemsShown = 0;
      var _loc3_ = this.GetClipByIndex(this.iMaxItemsShown);
      while(_loc3_ != undefined)
      {
         _loc3_.clipIndex = this.iMaxItemsShown;
         _loc3_.onRollOver = function()
         {
            if(!this._parent.listAnimating && !this._parent.bDisableInput && this.itemIndex != undefined)
            {
               this._parent.doSetSelectedIndex(this.itemIndex,0);
               this._parent.bMouseDrivenNav = true;
            }
         };
         _loc3_.onPress = function(aiMouseIndex, aiKeyboardOrMouse)
         {
            if(this.itemIndex != undefined)
            {
               this._parent.onItemPress(aiKeyboardOrMouse);
               if(!this._parent.bDisableInput && this.onMousePress != undefined)
               {
                  this.onMousePress();
               }
            }
         };
         _loc3_.onPressAux = function(aiMouseIndex, aiKeyboardOrMouse, aiButtonIndex)
         {
            if(this.itemIndex != undefined)
            {
               this._parent.onItemPressAux(aiKeyboardOrMouse,aiButtonIndex);
            }
         };
         _loc3_ = this.GetClipByIndex(this.iMaxItemsShown = this.iMaxItemsShown + 1);
      }
   }
   function onLoad()
   {
      if(this.ListScrollbar != undefined)
      {
         this.ListScrollbar.position = 0;
         this.ListScrollbar.addEventListener("scroll",this,"onScroll");
      }
   }
   function ClearList()
   {
      this.EntriesA.splice(0,this.EntriesA.length);
   }
   function GetClipByIndex(aiIndex)
   {
      return this["Entry" + aiIndex];
   }
   function handleInput(details, pathToFocus)
   {
      var _loc2_ = false;
      if(!this.bDisableInput)
      {
         var _loc4_ = this.GetClipByIndex(this.__get__selectedIndex() - this.__get__scrollPosition());
         _loc2_ = _loc4_ != undefined && _loc4_.handleInput != undefined && _loc4_.handleInput(details,pathToFocus.slice(1));
         if(!_loc2_ && Shared.GlobalFunc.IsKeyPressed(details))
         {
            if(details.navEquivalent == gfx.ui.NavigationCode.UP)
            {
               this.moveSelectionUp();
               _loc2_ = true;
            }
            else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN)
            {
               this.moveSelectionDown();
               _loc2_ = true;
            }
            else if(!this.bDisableSelection && details.navEquivalent == gfx.ui.NavigationCode.ENTER)
            {
               this.onItemPress();
               _loc2_ = true;
            }
         }
      }
      return _loc2_;
   }
   function onMouseWheel(delta)
   {
      if(!this.bDisableInput)
      {
         var _loc2_ = Mouse.getTopMostEntity();
         while(_loc2_ && _loc2_ != undefined)
         {
            if(_loc2_ == this)
            {
               this.doSetSelectedIndex(-1,0);
               if(delta < 0)
               {
                  this.__set__scrollPosition(this.__get__scrollPosition() + 1);
               }
               else if(delta > 0)
               {
                  this.__set__scrollPosition(this.__get__scrollPosition() - 1);
               }
            }
            _loc2_ = _loc2_._parent;
         }
      }
   }
   function __get__selectedIndex()
   {
      return this.iSelectedIndex;
   }
   function __set__selectedIndex(aiNewIndex)
   {
      this.doSetSelectedIndex(aiNewIndex);
      return this.__get__selectedIndex();
   }
   function __get__listAnimating()
   {
      return this.bListAnimating;
   }
   function __set__listAnimating(abFlag)
   {
      this.bListAnimating = abFlag;
      return this.__get__listAnimating();
   }
   function doSetSelectedIndex(aiNewIndex, aiKeyboardOrMouse)
   {
      if(!this.bDisableSelection && aiNewIndex != this.iSelectedIndex)
      {
         var _loc2_ = this.iSelectedIndex;
         this.iSelectedIndex = aiNewIndex;
         if(_loc2_ != -1)
         {
            this.SetEntry(this.GetClipByIndex(this.EntriesA[_loc2_].clipIndex),this.EntriesA[_loc2_]);
         }
         if(this.iSelectedIndex != -1)
         {
            if(this.iPlatform != Shared.Platforms.CONTROLLER_PC)
            {
               if(this.iSelectedIndex < this.iScrollPosition)
               {
                  this.__set__scrollPosition(this.iSelectedIndex);
               }
               else if(this.iSelectedIndex >= this.iScrollPosition + this.iListItemsShown)
               {
                  this.__set__scrollPosition(Math.min(this.iSelectedIndex - this.iListItemsShown + 1,this.iMaxScrollPosition));
               }
               else
               {
                  this.SetEntry(this.GetClipByIndex(this.EntriesA[this.iSelectedIndex].clipIndex),this.EntriesA[this.iSelectedIndex]);
               }
            }
            else
            {
               this.SetEntry(this.GetClipByIndex(this.EntriesA[this.iSelectedIndex].clipIndex),this.EntriesA[this.iSelectedIndex]);
            }
         }
         this.dispatchEvent({type:"selectionChange",index:this.iSelectedIndex,keyboardOrMouse:aiKeyboardOrMouse});
      }
   }
   function __get__scrollPosition()
   {
      return this.iScrollPosition;
   }
   function __get__maxScrollPosition()
   {
      return this.iMaxScrollPosition;
   }
   function __set__scrollPosition(aiNewPosition)
   {
      if(aiNewPosition != this.iScrollPosition && aiNewPosition >= 0 && aiNewPosition <= this.iMaxScrollPosition)
      {
         if(this.ListScrollbar == undefined)
         {
            this.updateScrollPosition(aiNewPosition);
         }
         else
         {
            this.ListScrollbar.position = aiNewPosition;
         }
      }
      return this.__get__scrollPosition();
   }
   function updateScrollPosition(aiPosition)
   {
      this.iScrollPosition = aiPosition;
      this.UpdateList();
   }
   function __get__selectedEntry()
   {
      return this.EntriesA[this.iSelectedIndex];
   }
   function __get__entryList()
   {
      return this.EntriesA;
   }
   function __set__entryList(anewArray)
   {
      this.EntriesA = anewArray;
      return this.__get__entryList();
   }
   function __get__disableSelection()
   {
      return this.bDisableSelection;
   }
   function __set__disableSelection(abFlag)
   {
      this.bDisableSelection = abFlag;
      return this.__get__disableSelection();
   }
   function __get__disableInput()
   {
      return this.bDisableInput;
   }
   function __set__disableInput(abFlag)
   {
      this.bDisableInput = abFlag;
      return this.__get__disableInput();
   }
   function __get__maxEntries()
   {
      return this.iMaxItemsShown;
   }
   function __get__textOption()
   {
      return this.iTextOption;
   }
   function __set__textOption(strNewOption)
   {
      if(strNewOption == "None")
      {
         this.iTextOption = Shared.BSScrollingList.TEXT_OPTION_NONE;
      }
      else if(strNewOption == "Shrink To Fit")
      {
         this.iTextOption = Shared.BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT;
      }
      else if(strNewOption == "Multi-Line")
      {
         this.iTextOption = Shared.BSScrollingList.TEXT_OPTION_MULTILINE;
      }
      return this.__get__textOption();
   }
   function UpdateList()
   {
      var _loc6_ = this.GetClipByIndex(0)._y;
      var _loc4_ = 0;
      var _loc2_ = 0;
      while(_loc2_ < this.iScrollPosition)
      {
         this.EntriesA[_loc2_].clipIndex = undefined;
         _loc2_ = _loc2_ + 1;
      }
      this.iListItemsShown = 0;
      _loc2_ = this.iScrollPosition;
      while(_loc2_ < this.EntriesA.length && this.iListItemsShown < this.iMaxItemsShown && _loc4_ <= this.fListHeight)
      {
         var _loc3_ = this.GetClipByIndex(this.iListItemsShown);
         this.SetEntry(_loc3_,this.EntriesA[_loc2_]);
         this.EntriesA[_loc2_].clipIndex = this.iListItemsShown;
         _loc3_.itemIndex = _loc2_;
         _loc3_._y = _loc6_ + _loc4_;
         _loc3_._visible = true;
         _loc4_ = _loc4_ + _loc3_._height;
         if(_loc4_ <= this.fListHeight && this.iListItemsShown < this.iMaxItemsShown)
         {
            this.iListItemsShown = this.iListItemsShown + 1;
         }
         _loc2_ = _loc2_ + 1;
      }
      var _loc5_ = this.iListItemsShown;
      while(_loc5_ < this.iMaxItemsShown)
      {
         this.GetClipByIndex(_loc5_)._visible = false;
         _loc5_ = _loc5_ + 1;
      }
      if(this.ScrollUp != undefined)
      {
         this.ScrollUp._visible = this.__get__scrollPosition() > 0;
      }
      if(this.ScrollDown != undefined)
      {
         this.ScrollDown._visible = this.__get__scrollPosition() < this.iMaxScrollPosition;
      }
   }
   function InvalidateData()
   {
      var _loc2_ = this.iMaxScrollPosition;
      this.fListHeight = this.border._height;
      this.CalculateMaxScrollPosition();
      if(this.ListScrollbar != undefined)
      {
         if(_loc2_ == this.iMaxScrollPosition)
         {
            this.SetScrollbarVisibility();
         }
         else
         {
            this.ListScrollbar._visible = false;
            this.ListScrollbar.setScrollProperties(this.iMaxItemsShown,0,this.iMaxScrollPosition);
            if(this.iScrollbarDrawTimerID != undefined)
            {
               clearInterval(this.iScrollbarDrawTimerID);
            }
            this.iScrollbarDrawTimerID = setInterval(this,"SetScrollbarVisibility",50);
         }
      }
      if(this.iSelectedIndex >= this.EntriesA.length)
      {
         this.iSelectedIndex = this.EntriesA.length - 1;
      }
      if(this.iScrollPosition > this.iMaxScrollPosition)
      {
         this.iScrollPosition = this.iMaxScrollPosition;
      }
      this.UpdateList();
   }
   function SetScrollbarVisibility()
   {
      clearInterval(this.iScrollbarDrawTimerID);
      this.iScrollbarDrawTimerID = undefined;
      this.ListScrollbar._visible = this.iMaxScrollPosition > 0;
   }
   function CalculateMaxScrollPosition()
   {
      var _loc3_ = 0;
      var _loc2_ = this.EntriesA.length - 1;
      while(_loc2_ >= 0 && _loc3_ <= this.fListHeight)
      {
         _loc3_ = _loc3_ + this.GetEntryHeight(_loc2_);
         if(_loc3_ <= this.fListHeight)
         {
            _loc2_ = _loc2_ - 1;
         }
      }
      this.iMaxScrollPosition = _loc2_ + 1;
   }
   function GetEntryHeight(aiEntryIndex)
   {
      var _loc2_ = this.GetClipByIndex(0);
      this.SetEntry(_loc2_,this.EntriesA[aiEntryIndex]);
      return _loc2_._height;
   }
   function moveSelectionUp()
   {
      if(!this.bDisableSelection)
      {
         if(this.__get__selectedIndex() > 0)
         {
            this.__set__selectedIndex(this.__get__selectedIndex() - 1);
         }
         return undefined;
      }
      this.__set__scrollPosition(this.__get__scrollPosition() - 1);
   }
   function moveSelectionDown()
   {
      if(!this.bDisableSelection)
      {
         if(this.__get__selectedIndex() < this.EntriesA.length - 1)
         {
            this.__set__selectedIndex(this.__get__selectedIndex() + 1);
         }
         return undefined;
      }
      this.__set__scrollPosition(this.__get__scrollPosition() + 1);
   }
   function onItemPress(aiKeyboardOrMouse)
   {
      if(!this.bDisableInput && !this.bDisableSelection && this.iSelectedIndex != -1)
      {
         this.dispatchEvent({type:"itemPress",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex],keyboardOrMouse:aiKeyboardOrMouse});
         return undefined;
      }
      this.dispatchEvent({type:"listPress"});
   }
   function onItemPressAux(aiKeyboardOrMouse, aiButtonIndex)
   {
      if(!this.bDisableInput && !this.bDisableSelection && this.iSelectedIndex != -1 && aiButtonIndex == 1)
      {
         this.dispatchEvent({type:"itemPressAux",index:this.iSelectedIndex,entry:this.EntriesA[this.iSelectedIndex],keyboardOrMouse:aiKeyboardOrMouse});
      }
   }
   function SetEntry(aEntryClip, aEntryObject)
   {
      if(aEntryClip != undefined)
      {
         if(aEntryObject == this.__get__selectedEntry())
         {
            aEntryClip.gotoAndStop("Selected");
         }
         else
         {
            aEntryClip.gotoAndStop("Normal");
         }
         this.SetEntryText(aEntryClip,aEntryObject);
      }
   }
   function SetEntryText(aEntryClip, aEntryObject)
   {
      if(aEntryClip.textField != undefined)
      {
         if(this.__get__textOption() == Shared.BSScrollingList.TEXT_OPTION_SHRINK_TO_FIT)
         {
            aEntryClip.textField.textAutoSize = "shrink";
         }
         else if(this.__get__textOption() == Shared.BSScrollingList.TEXT_OPTION_MULTILINE)
         {
            aEntryClip.textField.verticalAutoSize = "top";
         }
         if(aEntryObject.text == undefined)
         {
            aEntryClip.textField.SetText(" ");
         }
         else
         {
            aEntryClip.textField.SetText(aEntryObject.text);
         }
         if(aEntryObject.enabled != undefined)
         {
            aEntryClip.textField.textColor = aEntryObject.enabled != false?16777215:6316128;
         }
         if(aEntryObject.disabled != undefined)
         {
            aEntryClip.textField.textColor = aEntryObject.disabled != true?16777215:6316128;
         }
      }
   }
   function SetPlatform(aiPlatform, abPS3Switch)
   {
      this.iPlatform = aiPlatform;
      this.bMouseDrivenNav = this.iPlatform == Shared.Platforms.CONTROLLER_PC;
   }
   function onScroll(event)
   {
      this.updateScrollPosition(Math.floor(event.position + 0.5));
   }
}
