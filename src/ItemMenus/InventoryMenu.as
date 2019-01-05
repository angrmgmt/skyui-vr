class InventoryMenu extends ItemMenu
{
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = InventoryMenu.SKYUI_VERSION_MAJOR + "." + InventoryMenu.SKYUI_VERSION_MINOR + " SE";
   var _bMenuClosing = false;
   var _bSwitchMenus = false;
   var bPCControlsReady = true;
   function InventoryMenu()
   {
      super();
      this._categoryListIconArt = ["cat_favorites","inv_all","inv_weapons","inv_armor","inv_potions","inv_scrolls","inv_food","inv_ingredients","inv_books","inv_keys","inv_misc"];
      gfx.io.GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
      gfx.io.GameDelegate.addCallBack("DropItem",this,"DropItem");
      gfx.io.GameDelegate.addCallBack("AttemptChargeItem",this,"AttemptChargeItem");
      gfx.io.GameDelegate.addCallBack("ItemRotating",this,"ItemRotating");
   }
   function OnShow()
   {
      this._bMenuClosing = false;
      if(!this.bFadedIn)
      {
         this.inventoryLists.showPanel(false);
         this.itemCard.FadeInCard();
         this.ToggleMenuFade();
      }
   }
   function InitExtensions()
   {
      super.InitExtensions();
      Shared.GlobalFunc.AddReverseFunctions();
      this.inventoryLists.zoomButtonHolder.gotoAndStop(1);
      var _loc3_ = this.inventoryLists.categoryList;
      _loc3_.iconArt = this._categoryListIconArt;
      this.itemCard.addEventListener("itemPress",this,"onItemCardListPress");
   }
   function setConfig(a_config)
   {
      super.setConfig(a_config);
      var _loc3_ = this.inventoryLists.itemList;
      _loc3_.addDataProcessor(new InventoryDataSetter());
      _loc3_.addDataProcessor(new InventoryIconSetter(a_config.Appearance));
      _loc3_.addDataProcessor(new skyui.props.PropertyDataExtender(a_config.Appearance,a_config.Properties,"itemProperties","itemIcons","itemCompoundProperties"));
      var _loc5_ = skyui.components.list.ListLayoutManager.createLayout(a_config.ListLayout,"ItemListLayout");
      _loc3_.__set__layout(_loc5_);
      if(this.inventoryLists.categoryList.__get__selectedEntry())
      {
         _loc5_.changeFilterFlag(this.inventoryLists.categoryList.__get__selectedEntry().flag);
      }
   }
   function handleInput(details, pathToFocus)
   {
      if(!this.bFadedIn)
      {
         return true;
      }
      var _loc3_ = pathToFocus.shift();
      if(_loc3_.handleInput(details,pathToFocus))
      {
         return true;
      }
      if(Shared.GlobalFunc.IsKeyPressed(details))
      {
         if(details.navEquivalent == gfx.ui.NavigationCode.TAB || details.navEquivalent == gfx.ui.NavigationCode.SHIFT_TAB)
         {
            this.startMenuFade();
            gfx.io.GameDelegate.call("CloseTweenMenu",[]);
         }
         else if(!this.inventoryLists.itemList.disableInput)
         {
            if(details.skseKeycode == this._switchTabKey || details.control == "Quick Magic")
            {
               this.openMagicMenu(true);
            }
         }
      }
      return true;
   }
   function AttemptEquip(a_slot, a_bCheckOverList)
   {
      var _loc2_ = a_bCheckOverList == undefined?true:a_bCheckOverList;
      if(this.shouldProcessItemsListInput(_loc2_) && this.confirmSelectedEntry())
      {
         gfx.io.GameDelegate.call("ItemSelect",[a_slot]);
         this.checkBook(this.inventoryLists.itemList.__get__selectedEntry());
      }
   }
   function DropItem()
   {
      if(this.shouldProcessItemsListInput(false) && this.inventoryLists.itemList.__get__selectedEntry() != undefined)
      {
         if(this._quantityMinCount < 1 || this.inventoryLists.itemList.__get__selectedEntry().count < this._quantityMinCount)
         {
            this.onQuantityMenuSelect({amount:1});
         }
         else
         {
            this.itemCard.ShowQuantityMenu(this.inventoryLists.itemList.__get__selectedEntry().count);
         }
      }
   }
   function AttemptChargeItem()
   {
      if(this.inventoryLists.itemList.__get__selectedIndex() == -1)
      {
         return undefined;
      }
      if(this.shouldProcessItemsListInput(false) && this.itemCard.itemInfo.charge != undefined && this.itemCard.itemInfo.charge < 100)
      {
         gfx.io.GameDelegate.call("ShowSoulGemList",[]);
      }
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      this.inventoryLists.zoomButtonHolder.gotoAndStop(1);
      this.inventoryLists.zoomButtonHolder.ZoomButton._visible = a_platform != 0;
      this.inventoryLists.zoomButtonHolder.ZoomButton.SetPlatform(a_platform,a_bPS3Switch);
      super.SetPlatform(a_platform,a_bPS3Switch);
   }
   function ItemRotating()
   {
      this.inventoryLists.zoomButtonHolder.PlayForward(this.inventoryLists.zoomButtonHolder._currentframe);
   }
   function onExitMenuRectClick()
   {
      this.startMenuFade();
      gfx.io.GameDelegate.call("ShowTweenMenu",[]);
   }
   function onFadeCompletion()
   {
      if(!this._bMenuClosing)
      {
         return undefined;
      }
      gfx.io.GameDelegate.call("CloseMenu",[]);
      if(this._bSwitchMenus)
      {
         gfx.io.GameDelegate.call("CloseTweenMenu",[]);
         skse.OpenMenu("MagicMenu");
      }
   }
   function onShowItemsList(event)
   {
      super.onShowItemsList(event);
      if(event.index != -1)
      {
         this.updateBottomBar(true);
         gfx.io.GameDelegate.call("SetShowingItemsList",[1]);
      }
   }
   function onItemHighlightChange(event)
   {
      super.onItemHighlightChange(event);
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
   }
   function onHideItemsList(event)
   {
      super.onHideItemsList(event);
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});
      this.updateBottomBar(false);
      gfx.io.GameDelegate.call("SetShowingItemsList",[0]);
   }
   function onItemSelect(event)
   {
      if(event.entry.enabled && event.keyboardOrMouse != 0)
      {
         gfx.io.GameDelegate.call("ItemSelect",[]);
         this.checkBook(event.entry);
      }
   }
   function onQuantityMenuSelect(event)
   {
      gfx.io.GameDelegate.call("ItemDrop",[event.amount]);
      gfx.io.GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
   }
   function onMouseRotationFastClick(aiMouseButton)
   {
      gfx.io.GameDelegate.call("CheckForMouseEquip",[aiMouseButton],this,"AttemptEquip");
   }
   function onItemCardListPress(event)
   {
      gfx.io.GameDelegate.call("ItemCardListCallback",[event.index]);
   }
   function onItemCardSubMenuAction(event)
   {
      super.onItemCardSubMenuAction(event);
      gfx.io.GameDelegate.call("QuantitySliderOpen",[event.opening]);
      if(event.menu == "list")
      {
         if(event.opening == true)
         {
            this.navPanel.clearButtons();
            this.navPanel.addButton({text:"$Select",controls:this._acceptControls});
            this.navPanel.addButton({text:"$Cancel",controls:this._cancelControls});
            this.navPanel.updateButtons(true);
         }
         else
         {
            gfx.io.GameDelegate.call("RequestItemCardInfo",[],this,"UpdateItemCardInfo");
            this.updateBottomBar(true);
         }
      }
   }
   function openMagicMenu(a_bFade)
   {
      if(a_bFade)
      {
         this._bSwitchMenus = true;
         this.startMenuFade();
      }
      else
      {
         this.saveIndices();
         gfx.io.GameDelegate.call("CloseMenu",[]);
         gfx.io.GameDelegate.call("CloseTweenMenu",[]);
         skse.OpenMenu("MagicMenu");
      }
   }
   function startMenuFade()
   {
      this.inventoryLists.hidePanel();
      this.itemCard.FadeOutCard();
      this.ToggleMenuFade();
      this.saveIndices();
      this._bMenuClosing = true;
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      if(a_bSelected)
      {
         var _loc6_ = {PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LTRT",ViveArt:"trigger_LR",MoveArt:"PS3_MOVE",OculusArt:"trigger_LR",WindowsMRArt:"trigger_LR"};
         var _loc4_ = {PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A",ViveArt:"trigger",MoveArt:"PS3_MOVE",OculusArt:"trigger",WindowsMRArt:"trigger"};
         var _loc3_ = undefined;
         var _loc2_ = undefined;
         switch(this.itemCard.itemInfo.type)
         {
            case skyui.defines.Inventory.ICT_BOOK:
               _loc3_ = "$Read";
               _loc2_ = _loc4_;
               break;
            case skyui.defines.Inventory.ICT_POTION:
               _loc3_ = "$Use";
               _loc2_ = _loc4_;
               break;
            case skyui.defines.Inventory.ICT_FOOD:
            case skyui.defines.Inventory.ICT_INGREDIENT:
               _loc3_ = "$Eat";
               _loc2_ = _loc4_;
               break;
            case skyui.defines.Inventory.ICT_ARMOR:
            case skyui.defines.Inventory.ICT_WEAPON:
               _loc3_ = "$Equip";
               _loc2_ = _loc6_;
         }
         if(_loc2_ != undefined)
         {
            this.navPanel.addButton({text:_loc3_,controls:skyui.util.Input.pickControls(this._platform,_loc2_)});
         }
         this.navPanel.addButton({text:"$Drop",controls:skyui.util.Input.pickControls(this._platform,{PCArt:"R",XBoxArt:"360_X",PS3Art:"PS3_X",ViveArt:"radial_Either_Up",MoveArt:"PS3_A",OculusArt:"OCC_X",WindowsMRArt:"radial_Either_Up"})});
         var _loc5_ = skyui.util.Input.pickControls(this._platform,{PCArt:"F",XBoxArt:"360_Y",PS3Art:"PS3_Y",ViveArt:"radial_Either_Right",MoveArt:"PS3_Y",OculusArt:"OCC_B",WindowsMRArt:"radial_Either_Right"});
         if(this.inventoryLists.itemList.__get__selectedEntry().filterFlag & this.inventoryLists.categoryList.__get__entryList()[0].flag != 0)
         {
            this.navPanel.addButton({text:"$Unfavorite",controls:_loc5_});
         }
         else
         {
            this.navPanel.addButton({text:"$Favorite",controls:_loc5_});
         }
         if(this.itemCard.itemInfo.charge != undefined && this.itemCard.itemInfo.charge < 100)
         {
            this.navPanel.addButton({text:"$Charge",controls:skyui.util.Input.pickControls(this._platform,{PCArt:"T",XBoxArt:"360_RB",PS3Art:"PS3_RB",ViveArt:"radial_Either_Left",MoveArt:"PS3_X",OculusArt:"OCC_Y",WindowsMRArt:"radial_Either_Left"})});
         }
      }
      else if(this._platform != 0)
      {
         this.navPanel.addButton({text:"$Column",controls:{namedKey:"Action_Up"}});
         this.navPanel.addButton({text:"$Order",controls:{namedKey:"Action_Double_Up"}});
      }
      this.navPanel.updateButtons(true);
   }
}
