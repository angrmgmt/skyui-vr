class skyui.components.list.TabularListEntry extends skyui.components.list.BasicListEntry
{
   var _layoutUpdateCount = -1;
   function TabularListEntry()
   {
      super();
   }
   function setEntry(a_entryObject, a_state)
   {
      var _loc11_ = (skyui.components.list.TabularList)a_state.list.__get__layout();
      this.selectIndicator._visible = a_entryObject == a_state.list.__get__selectedEntry();
      var _loc12_ = _loc11_.__get__layoutUpdateCount();
      if(this._layoutUpdateCount != _loc12_)
      {
         this._layoutUpdateCount = _loc12_;
         this.setEntryLayout(a_entryObject,a_state);
         this.setSpecificEntryLayout(a_entryObject,a_state);
      }
      var _loc8_ = undefined;
      var _loc6_ = 0;
      while(_loc6_ < _loc11_.__get__columnCount())
      {
         var _loc3_ = _loc11_.__get__columnLayoutData()[_loc6_];
         var _loc2_ = this[_loc3_.stageName];
         if(_loc8_ == undefined)
         {
            _loc8_ = _loc2_.getLineMetrics(0);
         }
         var _loc5_ = _loc3_.entryValue;
         if(_loc5_ != undefined)
         {
            if(_loc5_.charAt(0) == "@")
            {
               var _loc10_ = a_entryObject[_loc5_.slice(1)];
               _loc2_.SetText(_loc10_ == undefined?"-":_loc10_);
            }
            else
            {
               _loc2_.SetText(_loc5_);
            }
         }
         switch(_loc3_.type)
         {
            case skyui.components.list.ListLayout.COL_TYPE_EQUIP_ICON:
               this.formatEquipIcon(_loc2_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_ITEM_ICON:
               this.formatItemIcon(_loc2_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_NAME:
               this.formatName(_loc2_,a_entryObject,a_state);
               break;
            case skyui.components.list.ListLayout.COL_TYPE_TEXT:
            default:
               this.formatText(_loc2_,a_entryObject,a_state);
         }
         if(_loc3_.colorAttribute != undefined)
         {
            var _loc9_ = a_entryObject[_loc3_.colorAttribute];
            if(_loc9_ != undefined)
            {
               _loc2_.textColor = _loc9_;
            }
         }
         _loc2_._y = this.selectIndicator._y - _loc8_.descent + (this.selectIndicator._height - _loc8_.ascent) / 2;
         _loc6_ = _loc6_ + 1;
      }
   }
   function setSpecificEntryLayout(a_entryObject, a_state)
   {
   }
   function formatName(a_entryField, a_entryObject, a_state)
   {
   }
   function formatEquipIcon(a_entryField, a_entryObject, a_state)
   {
   }
   function formatItemIcon(a_entryField, a_entryObject, a_state)
   {
   }
   function formatText(a_entryField, a_entryObject, a_state)
   {
   }
   function setEntryLayout(a_entryObject, a_state)
   {
      var _loc5_ = (skyui.components.list.TabularList)a_state.list.__get__layout();
      this.background._width = this.selectIndicator._width = _loc5_.entryWidth;
      this.background._height = this.selectIndicator._height = _loc5_.entryHeight;
      var _loc4_ = 0;
      while(_loc4_ < _loc5_.__get__columnCount())
      {
         var _loc2_ = _loc5_.__get__columnLayoutData()[_loc4_];
         var _loc3_ = this[_loc2_.stageName];
         _loc3_._visible = true;
         _loc3_._x = _loc2_.x;
         _loc3_._y = _loc2_.y;
         if(_loc2_.width > 0)
         {
            _loc3_._width = _loc2_.width;
         }
         if(_loc2_.height > 0)
         {
            _loc3_._height = _loc2_.height;
         }
         if(_loc3_ instanceof TextField)
         {
            _loc3_.setTextFormat(_loc2_.textFormat);
         }
         _loc4_ = _loc4_ + 1;
      }
      var _loc6_ = _loc5_.__get__hiddenStageNames();
      _loc4_ = 0;
      while(_loc4_ < _loc6_.length)
      {
         this[_loc6_[_loc4_]]._visible = false;
         _loc4_ = _loc4_ + 1;
      }
   }
}
