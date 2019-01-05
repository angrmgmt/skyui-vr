class InventoryLists extends MovieClip
{
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = InventoryLists.SKYUI_VERSION_MAJOR + "." + InventoryLists.SKYUI_VERSION_MINOR + " SE";
   static var HIDE_PANEL = 0;
   static var SHOW_PANEL = 1;
   static var TRANSITIONING_TO_HIDE_PANEL = 2;
   static var TRANSITIONING_TO_SHOW_PANEL = 3;
   var _savedSelectionIndex = -1;
   var _searchKey = -1;
   var _switchTabKey = -1;
   var _sortOrderKey = -1;
   var _sortOrderKeyHeld = false;
   var _bTabbed = false;
   function InventoryLists()
   {
      super();
      skyui.util.GlobalFunctions.addArrayFunctions();
      gfx.events.EventDispatcher.initialize(this);
      this.gotoAndStop("NoPanels");
      gfx.io.GameDelegate.addCallBack("SetCategoriesList",this,"SetCategoriesList");
      gfx.io.GameDelegate.addCallBack("InvalidateListData",this,"InvalidateListData");
      this._typeFilter = new skyui.filter.ItemTypeFilter();
      this._nameFilter = new skyui.filter.NameFilter();
      this._sortFilter = new skyui.filter.SortFilter();
      this.categoryList = this.panelContainer.categoryList;
      this.categoryLabel = this.panelContainer.categoryLabel;
      this.itemList = this.panelContainer.itemList;
      this.searchWidget = this.panelContainer.searchWidget;
      this.columnSelectButton = this.panelContainer.columnSelectButton;
      skyui.util.ConfigManager.registerLoadCallback(this,"onConfigLoad");
      skyui.util.ConfigManager.registerUpdateCallback(this,"onConfigUpdate");
   }
   function __get__currentState()
   {
      return this._currentState;
   }
   function __set__currentState(a_newState)
   {
      if(a_newState == InventoryLists.SHOW_PANEL)
      {
         gfx.managers.FocusHandler.__get__instance().setFocus(this.itemList,0);
      }
      this._currentState = a_newState;
      return this.__get__currentState();
   }
   function __set__tabBarIconArt(a_iconArt)
   {
      this._tabBarIconArt = a_iconArt;
      if(this.tabBar)
      {
         this.tabBar.setIcons(this._tabBarIconArt[0],this._tabBarIconArt[1]);
      }
      return this.__get__tabBarIconArt();
   }
   function __get__tabBarIconArt()
   {
      return this._tabBarIconArt;
   }
   function onLoad()
   {
      this.categoryList.listEnumeration = new skyui.components.list.BasicEnumeration(this.categoryList.__get__entryList());
      var _loc2_ = new skyui.components.list.FilteredEnumeration(this.itemList.__get__entryList());
      _loc2_.addFilter(this._typeFilter);
      _loc2_.addFilter(this._nameFilter);
      _loc2_.addFilter(this._sortFilter);
      this.itemList.listEnumeration = _loc2_;
      this.itemList.listState.maxTextLength = 80;
      this._typeFilter.addEventListener("filterChange",this,"onFilterChange");
      this._nameFilter.addEventListener("filterChange",this,"onFilterChange");
      this._sortFilter.addEventListener("filterChange",this,"onFilterChange");
      this.categoryList.addEventListener("itemPress",this,"onCategoriesItemPress");
      this.categoryList.addEventListener("itemPressAux",this,"onCategoriesItemPress");
      this.categoryList.addEventListener("selectionChange",this,"onCategoriesListSelectionChange");
      this.itemList.disableInput = false;
      this.itemList.addEventListener("selectionChange",this,"onItemsListSelectionChange");
      this.itemList.addEventListener("sortChange",this,"onSortChange");
      this.itemList.addEventListener("listUpdated",this,"onItemsListUpdate");
      this.searchWidget.addEventListener("inputStart",this,"onSearchInputStart");
      this.searchWidget.addEventListener("inputEnd",this,"onSearchInputEnd");
      this.searchWidget.addEventListener("inputChange",this,"onSearchInputChange");
      this.columnSelectButton.addEventListener("press",this,"onColumnSelectButtonPress");
   }
   function InitExtensions()
   {
      this.categoryList.__set__suspended(true);
      this.itemList.__set__suspended(true);
   }
   function showPanel(a_bPlayBladeSound)
   {
      this.categoryList.__set__suspended(false);
      this.itemList.__set__suspended(false);
      this._currentState = InventoryLists.TRANSITIONING_TO_SHOW_PANEL;
      this.gotoAndPlay("PanelShow");
      this.dispatchEvent({type:"categoryChange",index:this.categoryList.__get__selectedIndex()});
      if(a_bPlayBladeSound != false)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      }
   }
   function hidePanel()
   {
      this._currentState = InventoryLists.TRANSITIONING_TO_HIDE_PANEL;
      this.gotoAndPlay("PanelHide");
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
   }
   function enableTabBar()
   {
      this._bTabbed = true;
      this.panelContainer.gotoAndPlay("tabbed");
      this.itemList.__set__listHeight(480);
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this._platform = a_platform;
      this.categoryList.setPlatform(a_platform,a_bPS3Switch);
      this.itemList.setPlatform(a_platform,a_bPS3Switch);
   }
   function handleInput(details, pathToFocus)
   {
      if(this._currentState != InventoryLists.SHOW_PANEL)
      {
         return false;
      }
      if(this._platform != 0)
      {
         if(details.skseKeycode == this._sortOrderKey)
         {
            if(details.value == "keyDown")
            {
               this._sortOrderKeyHeld = true;
               if(this._columnSelectDialog)
               {
                  skyui.util.DialogManager.close();
               }
               else
               {
                  this._columnSelectInterval = setInterval(this,"onColumnSelectButtonPress",1000,{type:"timeout"});
               }
               return true;
            }
            if(details.value == "keyUp")
            {
               this._sortOrderKeyHeld = false;
               if(this._columnSelectInterval == undefined)
               {
                  return true;
               }
               clearInterval(this._columnSelectInterval);
               delete this._columnSelectInterval;
               details.value = "keyDown";
            }
            else if(this._sortOrderKeyHeld && details.value == "keyHold")
            {
               this._sortOrderKeyHeld = false;
               if(this._columnSelectDialog)
               {
                  skyui.util.DialogManager.close();
               }
               return true;
            }
         }
         if(this._sortOrderKeyHeld)
         {
            return true;
         }
      }
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.skseKeycode == this._searchKey)
         {
            this.searchWidget.startInput();
            return true;
         }
         if(this.tabBar != undefined && details.skseKeycode == this._switchTabKey)
         {
            this.tabBar.tabToggle();
            return true;
         }
      }
      if(this.categoryList.handleInput(details,pathToFocus))
      {
         return true;
      }
      var _loc4_ = pathToFocus.shift();
      return _loc4_.handleInput(details,pathToFocus);
   }
   function getContentBounds()
   {
      var _loc2_ = this.panelContainer.ListBackground;
      return [_loc2_._x,_loc2_._y,_loc2_._width,_loc2_._height];
   }
   function showItemsList()
   {
      var _loc2_ = this.categoryList.lastSelectedIndex;
      this._categorySelections[_loc2_] = {selectedIndex:this.itemList.__get__selectedIndex(),scrollPosition:this.itemList.__get__scrollPosition()};
      this._currCategoryIndex = this.categoryList.selectedIndex;
      this.categoryLabel.textField.SetText(this.categoryList.__get__selectedEntry().text);
      this.itemList.__set__selectedIndex(-1);
      this.itemList.__set__scrollPosition(0);
      if(this.categoryList.__get__selectedEntry() != undefined)
      {
         this._typeFilter.changeFilterFlag(this.categoryList.__get__selectedEntry().flag);
         this.itemList.__get__layout().changeFilterFlag(this.categoryList.__get__selectedEntry().flag);
      }
      this.itemList.requestUpdate();
      this.dispatchEvent({type:"itemHighlightChange",index:this.itemList.__get__selectedIndex()});
      this.itemList.disableInput = false;
   }
   function SetCategoriesList()
   {
      var _loc14_ = 0;
      var _loc13_ = 1;
      var _loc6_ = 2;
      var _loc12_ = 3;
      this.categoryList.clearList();
      this._categorySelections = new Array();
      var _loc3_ = 0;
      var _loc5_ = 0;
      while(_loc3_ < arguments.length)
      {
         var _loc4_ = {text:arguments[_loc3_ + _loc14_],flag:arguments[_loc3_ + _loc13_],bDontHide:arguments[_loc3_ + _loc6_],savedItemIndex:0,filterFlag:(arguments[_loc3_ + _loc6_] != true?0:1)};
         this.categoryList.__get__entryList().push(_loc4_);
         if(_loc4_.flag == 0)
         {
            this.categoryList.dividerIndex = _loc5_;
         }
         this._categorySelections.push(undefined);
         _loc3_ = _loc3_ + _loc12_;
         _loc5_;
         _loc5_++;
      }
      if(this._bTabbed)
      {
         this.categoryList.__set__selectedIndex(0);
         this._leftTabText = this.categoryList.__get__entryList()[0].text;
         this._rightTabText = this.categoryList.__get__entryList()[this.categoryList.dividerIndex + 1].text;
         this.categoryList.__get__entryList()[0].text = this.categoryList.__get__entryList()[this.categoryList.dividerIndex + 1].text = "$ALL";
      }
      this.categoryList.InvalidateData();
   }
   function InvalidateListData()
   {
      var _loc4_ = this.categoryList.__get__selectedEntry().flag;
      var _loc3_ = 0;
      while(_loc3_ < this.categoryList.__get__entryList().length)
      {
         this.categoryList.__get__entryList()[_loc3_].filterFlag = !this.categoryList.__get__entryList()[_loc3_].bDontHide?0:1;
         _loc3_ = _loc3_ + 1;
      }
      this.itemList.InvalidateData();
      _loc3_ = 0;
      while(_loc3_ < this.itemList.__get__entryList().length)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.categoryList.__get__entryList().length)
         {
            if(this.categoryList.__get__entryList()[_loc2_].filterFlag == 0)
            {
               if(this.itemList.__get__entryList()[_loc3_].filterFlag & this.categoryList.__get__entryList()[_loc2_].flag)
               {
                  this.categoryList.__get__entryList()[_loc2_].filterFlag = 1;
               }
            }
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = _loc3_ + 1;
      }
      this.categoryList.UpdateList();
      if(_loc4_ != this.categoryList.__get__selectedEntry().flag)
      {
         this._typeFilter.itemFilter = this.categoryList.__get__selectedEntry().flag;
         this.dispatchEvent({type:"categoryChange",index:this.categoryList.__get__selectedIndex()});
      }
      if(this.itemList.__get__selectedIndex() == -1)
      {
         this.dispatchEvent({type:"showItemsList",index:-1});
      }
      else
      {
         this.dispatchEvent({type:"itemHighlightChange",index:this.itemList.__get__selectedIndex()});
      }
   }
   function onConfigLoad(event)
   {
      var _loc2_ = event.config;
      this._searchKey = _loc2_.Input.controls.pc.search;
      if(this._platform == 0)
      {
         this._switchTabKey = _loc2_.Input.controls.pc.switchTab;
      }
      else
      {
         this._switchTabKey = _loc2_.Input.controls.gamepad.switchTab;
         this._sortOrderKey = _loc2_.Input.controls.gamepad.sortOrder;
      }
   }
   function onFilterChange()
   {
      this.itemList.requestInvalidate();
   }
   function onTabBarLoad()
   {
      this.tabBar = this.panelContainer.tabBar;
      this.tabBar.setIcons(this._tabBarIconArt[0],this._tabBarIconArt[1]);
      this.tabBar.addEventListener("tabPress",this,"onTabPress");
      if(this.categoryList.dividerIndex != -1)
      {
         this.tabBar.setLabelText(this._leftTabText,this._rightTabText);
      }
   }
   function onColumnSelectButtonPress(event)
   {
      if(event.type == "timeout")
      {
         clearInterval(this._columnSelectInterval);
         delete this._columnSelectInterval;
      }
      if(this._columnSelectDialog)
      {
         skyui.util.DialogManager.close();
         return undefined;
      }
      this.openColumnSelectDialog();
   }
   function openColumnSelectDialog()
   {
      if(this._columnSelectDialog)
      {
         return undefined;
      }
      this._savedSelectionIndex = this.itemList.selectedIndex;
      this.itemList.__set__selectedIndex(-1);
      this.categoryList.disableSelection = this.categoryList.disableInput = true;
      this.itemList.disableSelection = this.itemList.disableInput = true;
      this.searchWidget.isDisabled = true;
      this._columnSelectDialog = skyui.util.DialogManager.open(this.panelContainer,"ColumnSelectDialog",{_x:554,_y:35,layout:this.itemList.__get__layout()});
      this._columnSelectDialog.addEventListener("dialogClosed",this,"onColumnSelectDialogClosed");
   }
   function onColumnSelectDialogClosed(event)
   {
      this.categoryList.disableSelection = this.categoryList.disableInput = false;
      this.itemList.disableSelection = this.itemList.disableInput = false;
      this.searchWidget.isDisabled = false;
      this.itemList.__set__selectedIndex(this._savedSelectionIndex);
   }
   function onConfigUpdate(event)
   {
      this.itemList.__get__layout().refresh();
   }
   function onCategoriesItemPress()
   {
      this.showItemsList();
   }
   function toggleTab()
   {
      var _loc2_ = this.tabBar.__get__activeTab() != skyui.components.TabBar.LEFT_TAB?skyui.components.TabBar.LEFT_TAB:skyui.components.TabBar.RIGHT_TAB;
      this.switchTab(_loc2_);
   }
   function switchTab(newTab)
   {
      if(this.categoryList.disableSelection || this.categoryList.disableInput || this.itemList.disableSelection || this.itemList.disableInput)
      {
         return undefined;
      }
      if(newTab == skyui.components.TabBar.LEFT_TAB)
      {
         this.tabBar.__set__activeTab(skyui.components.TabBar.LEFT_TAB);
         this.categoryList.__set__activeSegment(CategoryList.LEFT_SEGMENT);
      }
      else if(newTab == skyui.components.TabBar.RIGHT_TAB)
      {
         this.tabBar.__set__activeTab(skyui.components.TabBar.RIGHT_TAB);
         this.categoryList.__set__activeSegment(CategoryList.RIGHT_SEGMENT);
      }
      gfx.io.GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
      this.showItemsList();
   }
   function onTabPress(event)
   {
      this.switchTab(event.index);
   }
   function onCategoriesListSelectionChange(event)
   {
      this._categoryChanged = true;
      this.dispatchEvent({type:"categoryChange",index:event.index});
      if(event.index != -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function onItemsListSelectionChange(event)
   {
      this.dispatchEvent({type:"itemHighlightChange",index:event.index});
      if(event.index != -1)
      {
         gfx.io.GameDelegate.call("PlaySound",["UIMenuFocus"]);
      }
   }
   function onSortChange(event)
   {
      this._sortFilter.setSortBy(event.attributes,event.options);
   }
   function onItemsListUpdate()
   {
      if(!this._categoryChanged)
      {
         return undefined;
      }
      var _loc2_ = this._categorySelections[this._currCategoryIndex];
      if(_loc2_ != undefined)
      {
         this.itemList.__set__selectedIndex(_loc2_.selectedIndex);
         this.itemList.__set__scrollPosition(_loc2_.scrollPosition);
      }
      else
      {
         this.itemList.__set__selectedIndex(-1);
         this.itemList.__set__scrollPosition(0);
      }
      this._categoryChanged = false;
   }
   function onSearchInputStart(event)
   {
      this.categoryList.disableSelection = this.categoryList.disableInput = true;
      this.itemList.disableSelection = this.itemList.disableInput = true;
      this._nameFilter.__set__filterText("");
   }
   function onSearchInputChange(event)
   {
      this._nameFilter.__set__filterText(event.data);
   }
   function onSearchInputEnd(event)
   {
      this.categoryList.disableSelection = this.categoryList.disableInput = false;
      this.itemList.disableSelection = this.itemList.disableInput = false;
      this._nameFilter.__set__filterText(event.data);
   }
}
