class BottomBar extends MovieClip
{
   static var SKYUI_RELEASE_IDX = 2018;
   static var SKYUI_VERSION_MAJOR = 5;
   static var SKYUI_VERSION_MINOR = 2;
   static var SKYUI_VERSION_STRING = BottomBar.SKYUI_VERSION_MAJOR + "." + BottomBar.SKYUI_VERSION_MINOR + " SE";
   function BottomBar()
   {
      super();
      this._lastItemType = skyui.defines.Inventory.ICT_NONE;
      this._healthMeter = new Components.Meter(this.playerInfoCard.HealthRect.MeterInstance.Meter_mc);
      this._magickaMeter = new Components.Meter(this.playerInfoCard.MagickaRect.MeterInstance.Meter_mc);
      this._staminaMeter = new Components.Meter(this.playerInfoCard.StaminaRect.MeterInstance.Meter_mc);
      this._levelMeter = new Components.Meter(this.playerInfoCard.LevelMeterInstance.Meter_mc);
   }
   function positionElements(a_leftOffset, a_rightOffset)
   {
      this.buttonPanel._x = a_leftOffset;
      this.buttonPanel.updateButtons(true);
      this.playerInfoCard._x = a_rightOffset - this.playerInfoCard._width;
   }
   function showPlayerInfo()
   {
      this.playerInfoCard._alpha = 100;
   }
   function hidePlayerInfo()
   {
      this.playerInfoCard._alpha = 0;
   }
   function UpdatePlayerInfo(a_playerUpdateObj, a_itemUpdateObj)
   {
      this._playerInfoObj = a_playerUpdateObj;
      this.updatePerItemInfo(a_itemUpdateObj);
   }
   function updatePerItemInfo(a_itemUpdateObj)
   {
      var _loc2_ = this.playerInfoCard;
      var _loc5_ = a_itemUpdateObj.type;
      var _loc9_ = true;
      if(_loc5_ == undefined)
      {
         _loc5_ = this._lastItemType;
         if(a_itemUpdateObj == undefined)
         {
            a_itemUpdateObj = {type:this._lastItemType};
         }
      }
      else
      {
         this._lastItemType = _loc5_;
      }
      if(this._playerInfoObj != undefined && a_itemUpdateObj != undefined)
      {
         switch(_loc5_)
         {
            case skyui.defines.Inventory.ICT_ARMOR:
               skyui.util.Debug.log(">> updatePerItemInfo ICT_ARMOR");
               _loc2_.gotoAndStop("Armor");
               var _loc4_ = Math.floor(this._playerInfoObj.armor).toString();
               if(a_itemUpdateObj.armorChange != undefined)
               {
                  var _loc8_ = Math.round(a_itemUpdateObj.armorChange);
                  if(_loc8_ > 0)
                  {
                     _loc4_ = _loc4_ + " <font color=\'#189515\'>(+" + _loc8_.toString() + ")</font>";
                  }
                  else if(_loc8_ < 0)
                  {
                     _loc4_ = _loc4_ + " <font color=\'#FF0000\'>(" + _loc8_.toString() + ")</font>";
                  }
               }
               _loc2_.ArmorRatingValue.textAutoSize = "shrink";
               _loc2_.ArmorRatingValue.html = true;
               _loc2_.ArmorRatingValue.SetText(_loc4_,true);
               skyui.util.Debug.log("Setting to text to: " + _loc4_);
               skyui.util.Debug.log("<< updatePerItemInfo ICT_ARMOR");
               this.updateFrostfallValues(a_itemUpdateObj);
               break;
            case skyui.defines.Inventory.ICT_WEAPON:
               _loc2_.gotoAndStop("Weapon");
               var _loc6_ = Math.floor(this._playerInfoObj.damage).toString();
               if(a_itemUpdateObj.damageChange != undefined)
               {
                  var _loc7_ = Math.round(a_itemUpdateObj.damageChange);
                  if(_loc7_ > 0)
                  {
                     _loc6_ = _loc6_ + " <font color=\'#189515\'>(+" + _loc7_.toString() + ")</font>";
                  }
                  else if(_loc7_ < 0)
                  {
                     _loc6_ = _loc6_ + " <font color=\'#FF0000\'>(" + _loc7_.toString() + ")</font>";
                  }
               }
               _loc2_.DamageValue.textAutoSize = "shrink";
               _loc2_.DamageValue.html = true;
               _loc2_.DamageValue.SetText(_loc6_,true);
               break;
            case skyui.defines.Inventory.ICT_POTION:
            case skyui.defines.Inventory.ICT_FOOD:
               var _loc12_ = 0;
               var _loc11_ = 1;
               var _loc10_ = 2;
               if(a_itemUpdateObj.potionType == _loc11_)
               {
                  _loc2_.gotoAndStop("MagickaPotion");
               }
               else if(a_itemUpdateObj.potionType == _loc10_)
               {
                  _loc2_.gotoAndStop("StaminaPotion");
               }
               else if(a_itemUpdateObj.potionType == _loc12_)
               {
                  _loc2_.gotoAndStop("HealthPotion");
               }
               break;
            case skyui.defines.Inventory.ICT_SPELL_DEFAULT:
            case skyui.defines.Inventory.ICT_ACTIVE_EFFECT:
               _loc2_.gotoAndStop("Magic");
               _loc9_ = false;
               break;
            case skyui.defines.Inventory.ICT_SPELL:
               _loc2_.gotoAndStop("MagicSkill");
               if(a_itemUpdateObj.magicSchoolName != undefined)
               {
                  this.updateSkillBar(a_itemUpdateObj.magicSchoolName,a_itemUpdateObj.magicSchoolLevel,a_itemUpdateObj.magicSchoolPct);
               }
               _loc9_ = false;
               break;
            case skyui.defines.Inventory.ICT_SHOUT:
               _loc2_.gotoAndStop("Shout");
               _loc2_.DragonSoulTextInstance.SetText(this._playerInfoObj.dragonSoulText);
               _loc9_ = false;
               break;
            case skyui.defines.Inventory.ICT_BOOK:
            case skyui.defines.Inventory.ICT_INGREDIENT:
            case skyui.defines.Inventory.ICT_MISC:
            case skyui.defines.Inventory.ICT_KEY:
            default:
               _loc2_.gotoAndStop("Default");
         }
         if(_loc9_)
         {
            _loc2_.CarryWeightValue.textAutoSize = "shrink";
            _loc2_.CarryWeightValue.SetText(Math.ceil(this._playerInfoObj.encumbrance) + "/" + Math.floor(this._playerInfoObj.maxEncumbrance));
            _loc2_.PlayerGoldValue.textAutoSize = "shrink";
            _loc2_.PlayerGoldValue.SetText(this._playerInfoObj.gold.toString());
            _loc2_.PlayerGoldLabel._x = _loc2_.PlayerGoldValue._x + _loc2_.PlayerGoldValue.getLineMetrics(0).x - _loc2_.PlayerGoldLabel._width;
            _loc2_.CarryWeightValue._x = _loc2_.PlayerGoldLabel._x + _loc2_.PlayerGoldLabel.getLineMetrics(0).x - _loc2_.CarryWeightValue._width - 5;
            _loc2_.CarryWeightLabel._x = _loc2_.CarryWeightValue._x + _loc2_.CarryWeightValue.getLineMetrics(0).x - _loc2_.CarryWeightLabel._width;
            if(_loc5_ === skyui.defines.Inventory.ICT_ARMOR)
            {
               _loc2_.ArmorRatingValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.ArmorRatingValue._width - 5;
               _loc2_.ArmorRatingLabel._x = _loc2_.ArmorRatingValue._x + _loc2_.ArmorRatingValue.getLineMetrics(0).x - _loc2_.ArmorRatingLabel._width;
               this.updateFrostfallElementPositions();
            }
            else if(_loc5_ === skyui.defines.Inventory.ICT_WEAPON)
            {
               _loc2_.DamageValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.DamageValue._width - 5;
               _loc2_.DamageLabel._x = _loc2_.DamageValue._x + _loc2_.DamageValue.getLineMetrics(0).x - _loc2_.DamageLabel._width;
            }
         }
         this.updateStatMeter(_loc2_.HealthRect,this._healthMeter,this._playerInfoObj.health,this._playerInfoObj.maxHealth,this._playerInfoObj.healthColor);
         this.updateStatMeter(_loc2_.MagickaRect,this._magickaMeter,this._playerInfoObj.magicka,this._playerInfoObj.maxMagicka,this._playerInfoObj.magickaColor);
         this.updateStatMeter(_loc2_.StaminaRect,this._staminaMeter,this._playerInfoObj.stamina,this._playerInfoObj.maxStamina,this._playerInfoObj.staminaColor);
      }
   }
   function UpdateCraftingInfo(a_skillName, a_levelStart, a_levelPercent)
   {
      this.playerInfoCard.gotoAndStop("Crafting");
      this.updateSkillBar(a_skillName,a_levelStart,a_levelPercent);
   }
   function updateBarterInfo(a_playerUpdateObj, a_itemUpdateObj, a_playerGold, a_vendorGold, a_vendorName)
   {
      this._playerInfoObj = a_playerUpdateObj;
      var _loc2_ = this.playerInfoCard;
      _loc2_.gotoAndStop("Barter");
      _loc2_.CarryWeightValue.textAutoSize = "shrink";
      _loc2_.CarryWeightValue.SetText(Math.ceil(this._playerInfoObj.encumbrance) + "/" + Math.floor(this._playerInfoObj.maxEncumbrance));
      _loc2_.VendorGoldLabel.textAutoSize = "shrink";
      if(a_vendorName != undefined)
      {
         _loc2_.VendorGoldLabel.SetText("$Gold");
         _loc2_.VendorGoldLabel.SetText(a_vendorName + " " + _loc2_.VendorGoldLabel.text);
      }
      this.updateBarterPriceInfo(a_playerGold,a_vendorGold,a_itemUpdateObj);
   }
   function updateBarterPriceInfo(a_playerGold, a_vendorGold, a_itemUpdateObj, a_goldDelta)
   {
      var _loc2_ = this.playerInfoCard;
      _loc2_.PlayerGoldValue.textAutoSize = "shrink";
      if(a_goldDelta == undefined)
      {
         _loc2_.PlayerGoldValue.SetText(a_playerGold.toString(),true);
      }
      else if(a_goldDelta >= 0)
      {
         _loc2_.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#189515\'>(+" + a_goldDelta.toString() + ")</font>",true);
      }
      else
      {
         _loc2_.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#FF0000\'>(" + a_goldDelta.toString() + ")</font>",true);
      }
      _loc2_.VendorGoldValue.textAutoSize = "shrink";
      _loc2_.VendorGoldValue.SetText(a_vendorGold.toString());
      _loc2_.VendorGoldLabel._x = _loc2_.VendorGoldValue._x + _loc2_.VendorGoldValue.getLineMetrics(0).x - _loc2_.VendorGoldLabel._width;
      _loc2_.PlayerGoldValue._x = _loc2_.VendorGoldLabel._x + _loc2_.VendorGoldLabel.getLineMetrics(0).x - _loc2_.PlayerGoldValue._width - 10;
      _loc2_.PlayerGoldLabel._x = _loc2_.PlayerGoldValue._x + _loc2_.PlayerGoldValue.getLineMetrics(0).x - _loc2_.PlayerGoldLabel._width;
      _loc2_.CarryWeightValue._x = _loc2_.PlayerGoldLabel._x + _loc2_.PlayerGoldLabel.getLineMetrics(0).x - _loc2_.CarryWeightValue._width - 5;
      _loc2_.CarryWeightLabel._x = _loc2_.CarryWeightValue._x + _loc2_.CarryWeightValue.getLineMetrics(0).x - _loc2_.CarryWeightLabel._width;
      this.updateBarterPerItemInfo(a_itemUpdateObj);
   }
   function updateBarterPerItemInfo(a_itemUpdateObj)
   {
      var _loc2_ = this.playerInfoCard;
      var _loc8_ = a_itemUpdateObj.type;
      if(_loc8_ == undefined)
      {
         _loc8_ = this._lastItemType;
         if(a_itemUpdateObj == undefined)
         {
            a_itemUpdateObj = {type:this._lastItemType};
         }
      }
      else
      {
         this._lastItemType = _loc8_;
      }
      if(a_itemUpdateObj != undefined)
      {
         _loc8_ = a_itemUpdateObj.type;
         switch(_loc8_)
         {
            case skyui.defines.Inventory.ICT_ARMOR:
               _loc2_.gotoAndStop("Barter_Armor");
               var _loc5_ = Math.floor(this._playerInfoObj.armor).toString();
               if(a_itemUpdateObj.armorChange != undefined)
               {
                  var _loc7_ = Math.round(a_itemUpdateObj.armorChange);
                  if(_loc7_ > 0)
                  {
                     _loc5_ = _loc5_ + " <font color=\'#189515\'>(+" + _loc7_.toString() + ")</font>";
                  }
                  else if(_loc7_ < 0)
                  {
                     _loc5_ = _loc5_ + " <font color=\'#FF0000\'>(" + _loc7_.toString() + ")</font>";
                  }
               }
               _loc2_.ArmorRatingValue.textAutoSize = "shrink";
               _loc2_.ArmorRatingValue.html = true;
               _loc2_.ArmorRatingValue.SetText(_loc5_,true);
               _loc2_.ArmorRatingValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.ArmorRatingValue._width - 5;
               _loc2_.ArmorRatingLabel._x = _loc2_.ArmorRatingValue._x + _loc2_.ArmorRatingValue.getLineMetrics(0).x - _loc2_.ArmorRatingLabel._width;
               this.updateFrostfallValues(a_itemUpdateObj);
               this.updateFrostfallElementPositions();
               break;
            case skyui.defines.Inventory.ICT_WEAPON:
               _loc2_.gotoAndStop("Barter_Weapon");
               var _loc4_ = Math.floor(this._playerInfoObj.damage).toString();
               if(a_itemUpdateObj.damageChange != undefined)
               {
                  var _loc6_ = Math.round(a_itemUpdateObj.damageChange);
                  if(_loc6_ > 0)
                  {
                     _loc4_ = _loc4_ + " <font color=\'#189515\'>(+" + _loc6_.toString() + ")</font>";
                  }
                  else if(_loc6_ < 0)
                  {
                     _loc4_ = _loc4_ + " <font color=\'#FF0000\'>(" + _loc6_.toString() + ")</font>";
                  }
               }
               _loc2_.DamageValue.textAutoSize = "shrink";
               _loc2_.DamageValue.html = true;
               _loc2_.DamageValue.SetText(_loc4_,true);
               _loc2_.DamageValue._x = _loc2_.CarryWeightLabel._x + _loc2_.CarryWeightLabel.getLineMetrics(0).x - _loc2_.DamageValue._width - 5;
               _loc2_.DamageLabel._x = _loc2_.DamageValue._x + _loc2_.DamageValue.getLineMetrics(0).x - _loc2_.DamageLabel._width;
               break;
            default:
               _loc2_.gotoAndStop("Barter");
         }
      }
   }
   function setGiftInfo(a_favorPoints)
   {
      this.playerInfoCard.gotoAndStop("Gift");
   }
   function setPlatform(a_platform, a_bPS3Switch)
   {
      this.buttonPanel.setPlatform(a_platform,a_bPS3Switch);
   }
   function GoToDefaultFrame()
   {
      this.playerInfoCard.gotoAndStop("Default");
   }
   function updateStatMeter(a_meterRect, a_meterObj, a_currValue, a_maxValue, a_colorStr)
   {
      if(a_colorStr == undefined)
      {
         a_colorStr = "#FFFFFF";
      }
      if(a_meterRect._alpha > 0)
      {
         if(a_meterRect.MeterText != undefined)
         {
            a_meterRect.MeterText.textAutoSize = "shrink";
            a_meterRect.MeterText.html = true;
            a_meterRect.MeterText.SetText("<font color=\'" + a_colorStr + "\'>" + Math.floor(a_currValue) + "/" + Math.floor(a_maxValue) + "</font>",true);
         }
         a_meterRect.MeterInstance.gotoAndStop("Pause");
         a_meterObj.SetPercent(a_currValue / a_maxValue * 100);
      }
   }
   function updateSkillBar(a_skillName, a_levelStart, a_levelPercent)
   {
      var _loc2_ = this.playerInfoCard;
      _loc2_.SkillLevelLabel.SetText(a_skillName);
      _loc2_.SkillLevelCurrent.SetText(a_levelStart);
      _loc2_.SkillLevelNext.SetText(a_levelStart + 1);
      _loc2_.LevelMeterInstance.gotoAndStop("Pause");
      this._levelMeter.SetPercent(a_levelPercent);
   }
   function updateFrostfallWarmth(warmth)
   {
      this._currentTotalWarmth = warmth;
      this.updateFrostfallWarmthFromStoredValues();
      this.updateFrostfallElementPositions();
   }
   function updateFrostfallCoverage(coverage)
   {
      this._currentTotalCoverage = coverage;
      this.updateFrostfallCoverageFromStoredValues();
      this.updateFrostfallElementPositions();
   }
   function updateFrostfallElementPositions()
   {
      var _loc2_ = this.playerInfoCard;
      _loc2_.RainProtectionValue._x = _loc2_.ArmorRatingLabel._x + _loc2_.ArmorRatingLabel.getLineMetrics(0).x - _loc2_.RainProtectionValue._width - 5;
      _loc2_.RainProtectionLabel._x = _loc2_.RainProtectionValue._x + _loc2_.RainProtectionValue.getLineMetrics(0).x - _loc2_.RainProtectionLabel._width;
      _loc2_.ExposureProtectionValue._x = _loc2_.RainProtectionLabel._x + _loc2_.RainProtectionLabel.getLineMetrics(0).x - _loc2_.ExposureProtectionValue._width - 5;
      _loc2_.ExposureProtectionLabel._x = _loc2_.ExposureProtectionValue._x + _loc2_.ExposureProtectionValue.getLineMetrics(0).x - _loc2_.ExposureProtectionLabel._width;
   }
   function updateFrostfallValues(a_itemUpdateObj)
   {
      var _loc2_ = this.playerInfoCard;
      var _loc4_ = this._currentTotalWarmth.toString();
      if(a_itemUpdateObj.currentArmorWarmth !== undefined)
      {
         _loc6_ = a_itemUpdateObj.warmth - a_itemUpdateObj.currentArmorWarmth;
         if(_loc6_ > 0)
         {
            this._lastWarmthDelta = " <font color=\'#189515\'>(+" + _loc6_.toString() + ")</font>";
            _loc4_ = _loc4_ + this._lastWarmthDelta;
         }
         else if(_loc6_ < 0)
         {
            this._lastWarmthDelta = " <font color=\'#FF0000\'>(" + _loc6_.toString() + ")</font>";
            _loc4_ = _loc4_ + this._lastWarmthDelta;
         }
         else
         {
            this._lastWarmthDelta = "";
         }
      }
      _loc2_.ExposureProtectionValue.textAutoSize = "shrink";
      _loc2_.ExposureProtectionValue.html = true;
      _loc2_.ExposureProtectionValue.SetText(_loc4_,true);
      var _loc3_ = this._currentTotalCoverage.toString();
      if(a_itemUpdateObj.currentArmorCoverage !== undefined)
      {
         _loc5_ = a_itemUpdateObj.coverage - a_itemUpdateObj.currentArmorCoverage;
         if(_loc5_ > 0)
         {
            this._lastCoverageDelta = " <font color=\'#189515\'>(+" + _loc5_.toString() + ")</font>";
            _loc3_ = _loc3_ + this._lastCoverageDelta;
         }
         else if(_loc5_ < 0)
         {
            this._lastCoverageDelta = " <font color=\'#FF0000\'>(" + _loc5_.toString() + ")</font>";
            _loc3_ = _loc3_ + this._lastCoverageDelta;
         }
         else
         {
            this._lastCoverageDelta = "";
         }
      }
      _loc2_.RainProtectionValue.textAutoSize = "shrink";
      _loc2_.RainProtectionValue.html = true;
      _loc2_.RainProtectionValue.SetText(_loc3_,true);
   }
   function updateFrostfallWarmthFromStoredValues()
   {
      var _loc3_ = this.playerInfoCard;
      var _loc2_ = this._currentTotalWarmth.toString();
      _loc2_ = _loc2_ + this._lastWarmthDelta;
      _loc3_.ExposureProtectionValue.textAutoSize = "shrink";
      _loc3_.ExposureProtectionValue.html = true;
      _loc3_.ExposureProtectionValue.SetText(_loc2_,true);
   }
   function updateFrostfallCoverageFromStoredValues()
   {
      var _loc3_ = this.playerInfoCard;
      var _loc2_ = this._currentTotalCoverage.toString();
      _loc2_ = _loc2_ + this._lastCoverageDelta;
      _loc3_.RainProtectionValue.textAutoSize = "shrink";
      _loc3_.RainProtectionValue.html = true;
      _loc3_.RainProtectionValue.SetText(_loc2_,true);
   }
}
