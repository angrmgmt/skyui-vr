class ContainerMenu extends ItemMenu
{
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = ContainerMenu.SKYUI_VERSION_MAJOR + "." + ContainerMenu.SKYUI_VERSION_MINOR + " SE";
   static var NULL_HAND = -1;
   static var RIGHT_HAND = 0;
   static var LEFT_HAND = 1;
   var _bEquipMode = false;
   var bNPCMode = false;
   var bEnableTabs = true;
   function ContainerMenu()
   {
      super();
      this._tabBarIconArt = ["take","give"];
      this._pauseInputHandling = false;
      this._columnOpRequested = 0;
   }
   function InitExtensions()
   {
      super.InitExtensions();
      this.inventoryLists.__set__tabBarIconArt(this._tabBarIconArt);
      this.inventoryLists.categoryList.iconArt = ["inv_all","inv_weapons","inv_armor","inv_potions","inv_scrolls","inv_food","inv_ingredients","inv_books","inv_keys","inv_misc"];
      gfx.io.GameDelegate.addCallBack("AttemptEquip",this,"AttemptEquip");
      gfx.io.GameDelegate.addCallBack("AttemptTake",this,"AttemptTake");
      gfx.io.GameDelegate.addCallBack("AttemptTakeAll",this,"AttemptTakeAll");
      gfx.io.GameDelegate.addCallBack("AttemptStore",this,"AttemptStore");
      gfx.io.GameDelegate.addCallBack("AttemptTakeAndEquip",this,"AttemptTakeAndEquip");
      gfx.io.GameDelegate.addCallBack("Vanilla_AttemptEquip",this,"Vanilla_AttemptEquip");
      gfx.io.GameDelegate.addCallBack("Vanilla_XButtonPress",this,"Vanilla_XButtonPress");
      this.itemCardFadeHolder.StealTextInstance._visible = false;
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
      this._equipModeKey = a_config.Input.controls.pc.equipMode;
      this._equipModeControls = {keyCode:this._equipModeKey};
   }
   function ShowItemsList()
   {
   }
   function handleInput(details, pathToFocus)
   {
      if(this._pauseInputHandling)
      {
         return true;
      }
      skyui.util.Input.rateLimit(this,"_pauseInputHandling",10);
      var _loc4_ = pathToFocus[0] != this.itemCard;
      if(_loc4_ && Shared.GlobalFunc.IsKeyPressed(details) && details.navEquivalent == gfx.ui.NavigationCode.LEFT && this.inventoryLists.categoryList.selectionAtBeginningOfSegment())
      {
         if(!this._pauseTabSwitch)
         {
            this.inventoryLists.toggleTab();
            skyui.util.Input.rateLimit(this,"_pauseTabSwitch",333.3333333333333);
         }
         return true;
      }
      super.handleInput(details,pathToFocus);
      if(this.shouldProcessItemsListInput(false))
      {
         if((this._platform == Shared.Platforms.CONTROLLER_PC || this._platform == Shared.Platforms.CONTROLLER_VIVE || this._platform == Shared.Platforms.CONTROLLER_OCULUS || this._platform == Shared.Platforms.CONTROLLER_WINDOWS_MR) && details.skseKeycode == this._equipModeKey && this.inventoryLists.itemList.__get__selectedIndex() != -1)
         {
            this._bEquipMode = details.value != "keyUp";
            this.updateBottomBar(true);
         }
      }
      return true;
   }
   function UpdateItemCardInfo(a_updateObj)
   {
      super.UpdateItemCardInfo(a_updateObj);
      this.updateBottomBar(true);
      if(a_updateObj.pickpocketChance != undefined)
      {
         this.itemCardFadeHolder.StealTextInstance._visible = true;
         this.itemCardFadeHolder.StealTextInstance.PercentTextInstance.html = true;
         this.itemCardFadeHolder.StealTextInstance.PercentTextInstance.htmlText = "<font face=\'$EverywhereBoldFont\' size=\'24\' color=\'#FFFFFF\'>" + a_updateObj.pickpocketChance + "%</font>" + (!this.isViewingContainer()?skyui.util.Translator.translate("$ TO PLACE"):skyui.util.Translator.translate("$ TO STEAL"));
      }
      else
      {
         this.itemCardFadeHolder.StealTextInstance._visible = false;
      }
   }
   function AttemptEquip(a_slot, a_bCheckOverList)
   {
   }
   function SetPlatform(a_platform, a_bPS3Switch)
   {
      super.SetPlatform(a_platform,a_bPS3Switch);
      this._bEquipMode = a_platform != 0;
   }
   function Vanilla_AttemptEquip(a_slot, a_bCheckOverList)
   {
      var _loc2_ = a_bCheckOverList != undefined?a_bCheckOverList:true;
      if(!this.shouldProcessItemsListInput(_loc2_) || !this.confirmSelectedEntry())
      {
         return undefined;
      }
      if(this._platform == Shared.Platforms.CONTROLLER_PC || this._platform == Shared.Platforms.CONTROLLER_VIVE || this._platform == Shared.Platforms.CONTROLLER_OCULUS || this._platform == Shared.Platforms.CONTROLLER_WINDOWS_MR)
      {
         if(this._bEquipMode)
         {
            this.startItemEquip(a_slot);
         }
         else
         {
            this.startItemTransfer();
         }
      }
      else
      {
         this.startItemEquip(a_slot);
      }
   }
   function AttemptTake(abCheckOverList)
   {
      var _loc2_ = abCheckOverList != undefined?abCheckOverList:true;
      if(this.shouldProcessItemsListInput(_loc2_))
      {
         this.startItemTransfer();
      }
   }
   function AttemptTakeAndEquip(aiSlot, abCheckOverList)
   {
      var _loc2_ = abCheckOverList != undefined?abCheckOverList:true;
      if(this.shouldProcessItemsListInput(_loc2_))
      {
         this.startItemEquip(aiSlot);
      }
   }
   function AttemptTakeAll()
   {
      if(this.isViewingContainer() && !this.bNPCMode)
      {
         gfx.io.GameDelegate.call("TakeAllItems",[]);
      }
   }
   function AttemptStore()
   {
      if(!this.isViewingContainer())
      {
         this.startItemTransfer();
      }
   }
   function Vanilla_XButtonPress()
   {
      if(!this.bFadedIn)
      {
         return undefined;
      }
      if(this.isViewingContainer() && !this.bNPCMode)
      {
         gfx.io.GameDelegate.call("TakeAllItems",[]);
      }
      else if(!this.isViewingContainer())
      {
         this.startItemTransfer();
      }
   }
   function onItemSelect(event)
   {
      if(event.keyboardOrMouse != 0)
      {
         if(this._platform == 0 && this._bEquipMode)
         {
            this.startItemEquip(ContainerMenu.NULL_HAND);
         }
         else
         {
            this.startItemTransfer();
         }
      }
   }
   function onItemCardSubMenuAction(event)
   {
      super.onItemCardSubMenuAction(event);
      if(event.menu == "quantity")
      {
         gfx.io.GameDelegate.call("QuantitySliderOpen",[event.opening]);
      }
   }
   function onItemHighlightChange(event)
   {
      if(event.index != -1)
      {
         this.updateBottomBar(true);
      }
      super.onItemHighlightChange(event);
   }
   function onShowItemsList(event)
   {
      this.inventoryLists.showItemsList();
   }
   function onHideItemsList(event)
   {
      super.onHideItemsList(event);
      this.bottomBar.updatePerItemInfo({type:skyui.defines.Inventory.ICT_NONE});
      this.updateBottomBar(false);
   }
   function onMouseRotationFastClick(a_mouseButton)
   {
      gfx.io.GameDelegate.call("CheckForMouseEquip",[a_mouseButton],this,"AttemptEquip");
   }
   function onQuantityMenuSelect(event)
   {
      if(this._equipHand != undefined)
      {
         gfx.io.GameDelegate.call("EquipItem",[this._equipHand,event.amount]);
         if(!this.checkBook(this.inventoryLists.itemList.__get__selectedEntry()))
         {
            this.checkPoison(this.inventoryLists.itemList.__get__selectedEntry());
         }
         this._equipHand = undefined;
         return undefined;
      }
      if(this.inventoryLists.itemList.__get__selectedEntry().enabled)
      {
         gfx.io.GameDelegate.call("ItemTransfer",[event.amount,this.isViewingContainer()]);
         return undefined;
      }
      gfx.io.GameDelegate.call("DisabledItemSelect",[]);
   }
   function updateBottomBar(a_bSelected)
   {
      this.navPanel.clearButtons();
      var _loc15_ = skyui.util.Input.pickControls(this._platform,{PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LTRT",ViveArt:"trigger_LR",MoveArt:"PS3_A",OculusArt:"trigger_LR",WindowsMRArt:"trigger_LR"});
      var _loc5_ = skyui.util.Input.pickControls(this._platform,{PCArt:"R",XBoxArt:"360_X",PS3Art:"PS3_X",ViveArt:"radial_Either_Left",MoveArt:"PS3_B",OculusArt:"OCC_Y",WindowsMRArt:"radial_Either_Left"});
      var _loc6_ = skyui.util.Input.pickControls(this._platform,{PCArt:"E",XBoxArt:"360_A",PS3Art:"PS3_A",ViveArt:"radial_Either_Center",MoveArt:"PS3_MOVE",OculusArt:"OCC_A",WindowsMRArt:"radial_Either_Center"});
      var _loc8_ = skyui.util.Input.pickControls(this._platform,{PCArt:"F",XBoxArt:"360_Y",PS3Art:"PS3_Y",ViveArt:"radial_Either_Right",MoveArt:"PS3_Y",OculusArt:"OCC_B",WindowsMRArt:"radial_Either_Right"});
      var _loc7_ = {PCArt:"M1M2",XBoxArt:"360_LTRT",PS3Art:"PS3_LTRT",ViveArt:"trigger_LR",MoveArt:"PS3_MOVE",OculusArt:"trigger_LR",WindowsMRArt:"trigger_LR"};
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
            _loc2_ = _loc7_;
      }
      if(_loc2_ != undefined)
      {
         this.navPanel.addButton({text:_loc3_,controls:skyui.util.Input.pickControls(this._platform,_loc2_)});
      }
      if(a_bSelected && this.inventoryLists.itemList.__get__selectedIndex() != -1 && this.inventoryLists.__get__currentState() == InventoryLists.SHOW_PANEL)
      {
         if(this.isViewingContainer())
         {
            this.navPanel.addButton({text:"$Take",controls:_loc6_});
            if(!this.bNPCMode)
            {
               this.navPanel.addButton({text:"$Take All",controls:_loc5_});
            }
         }
         else
         {
            this.navPanel.addButton({text:(!this.bNPCMode?"$Store":"$Give"),controls:_loc6_});
            this.navPanel.addButton({text:(!this.itemCard.itemInfo.favorite?"$Favorite":"$Unfavorite"),controls:_loc8_});
         }
      }
      else
      {
         if(this._platform != 0)
         {
            this.navPanel.addButton({text:"$Column",controls:{namedKey:"Action_Up"}});
            this.navPanel.addButton({text:"$Order",controls:{namedKey:"Action_Double_Up"}});
         }
         this.navPanel.addButton({text:"$Switch Tab",controls:{namedKey:"Action_Left"}});
         if(this.isViewingContainer() && !this.bNPCMode)
         {
            this.navPanel.addButton({text:"$Take All",controls:_loc5_});
         }
      }
      this.navPanel.updateButtons(true);
   }
   function startItemTransfer()
   {
      if(this.inventoryLists.itemList.__get__selectedEntry().enabled)
      {
         if(this.itemCard.itemInfo.weight == 0 && this.isViewingContainer())
         {
            this.onQuantityMenuSelect({amount:this.inventoryLists.itemList.__get__selectedEntry().count});
            return undefined;
         }
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
   function startItemEquip(a_equipHand)
   {
      if(this.isViewingContainer())
      {
         this._equipHand = a_equipHand;
         this.startItemTransfer();
         return undefined;
      }
      gfx.io.GameDelegate.call("EquipItem",[a_equipHand]);
      if(!this.checkBook(this.inventoryLists.itemList.__get__selectedEntry()))
      {
         this.checkPoison(this.inventoryLists.itemList.__get__selectedEntry());
      }
   }
   function isViewingContainer()
   {
      return this.inventoryLists.categoryList.__get__activeSegment() == 0;
   }
   function checkPoison(a_entryObject)
   {
      if(a_entryObject.type != skyui.defines.Inventory.ICT_POTION || _global.skse == null)
      {
         return false;
      }
      if(a_entryObject.subType != skyui.defines.Item.POTION_POISON)
      {
         return false;
      }
      this._bEquipMode = false;
      return true;
   }
}
