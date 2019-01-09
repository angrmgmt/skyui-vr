﻿import gfx.io.GameDelegate;
import Components.Meter;

import skyui.components.ButtonPanel;
import skyui.defines.Inventory;


class BottomBar extends MovieClip
{
	#include "../version.as"
	
  /* PRIVATE VARIABLES */	
  
	private var _lastItemType: Number;
	
	private var _healthMeter: Meter;
	private var _magickaMeter: Meter;
	private var _staminaMeter: Meter;
	private var _levelMeter: Meter;

	private var _playerInfoObj: Object;
	
	//Frostfall
	private var _currentTotalWarmth: Number;
	private var _currentTotalCoverage: Number;
	private var _lastWarmthDelta: String;
	private var _lastCoverageDelta: String;
	
  /* STAGE ELEMENTS */

	public var playerInfoCard: MovieClip;
	
	
  /* PROPERTIES */
  
	public var buttonPanel: ButtonPanel;
	
	
  /* INITIALIZATION */

	public function BottomBar()
	{
		super();
		_lastItemType = Inventory.ICT_NONE;
		_healthMeter = new Meter(playerInfoCard.HealthRect.MeterInstance.Meter_mc);
		_magickaMeter = new Meter(playerInfoCard.MagickaRect.MeterInstance.Meter_mc);
		_staminaMeter = new Meter(playerInfoCard.StaminaRect.MeterInstance.Meter_mc);
		_levelMeter = new Meter(playerInfoCard.LevelMeterInstance.Meter_mc);
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function positionElements(a_leftOffset: Number, a_rightOffset: Number): Void
	{
		buttonPanel._x = a_leftOffset;
		buttonPanel.updateButtons(true);
		playerInfoCard._x = a_rightOffset - playerInfoCard._width;
	}

	public function showPlayerInfo(): Void
	{
		playerInfoCard._alpha = 100;
	}

	public function hidePlayerInfo(): Void
	{
		playerInfoCard._alpha = 0;
	}

	// @API
	public function UpdatePlayerInfo(a_playerUpdateObj: Object, a_itemUpdateObj: Object): Void
	{
		_playerInfoObj = a_playerUpdateObj;
		updatePerItemInfo(a_itemUpdateObj);
	}

	public function updatePerItemInfo(a_itemUpdateObj: Object): Void
	{
		var infoCard = playerInfoCard;
		var itemType: Number = a_itemUpdateObj.type;
		var bHasWeightandValue = true;
		
		if (itemType == undefined) {
			itemType = _lastItemType;
			if (a_itemUpdateObj == undefined)
				a_itemUpdateObj = {type: _lastItemType};
		} else {
			_lastItemType = itemType;
		}
		if (_playerInfoObj != undefined && a_itemUpdateObj != undefined) {
			switch(itemType) {
				case Inventory.ICT_ARMOR:
					infoCard.gotoAndStop("Armor");
					var strArmor: String = Math.floor(_playerInfoObj.armor).toString();
					if (a_itemUpdateObj.armorChange != undefined) {
						var iArmorDelta = Math.round(a_itemUpdateObj.armorChange);
						if (iArmorDelta > 0) 
							strArmor = strArmor + " <font color=\'#189515\'>(+" + iArmorDelta.toString() + ")</font>";
						else if (iArmorDelta < 0) 
							strArmor = strArmor + " <font color=\'#FF0000\'>(" + iArmorDelta.toString() + ")</font>";
					}
					infoCard.ArmorRatingValue.textAutoSize = "shrink";
					infoCard.ArmorRatingValue.html = true;
					infoCard.ArmorRatingValue.SetText(strArmor, true);
					updateFrostfallValues(a_itemUpdateObj);
					break;
					
				case Inventory.ICT_WEAPON:
					infoCard.gotoAndStop("Weapon");
					var strDamage: String = Math.floor(_playerInfoObj.damage).toString();
					if (a_itemUpdateObj.damageChange != undefined) {
						var iDamageDelta = Math.round(a_itemUpdateObj.damageChange);
						if (iDamageDelta > 0) 
							strDamage = strDamage + " <font color=\'#189515\'>(+" + iDamageDelta.toString() + ")</font>";
						else if (iDamageDelta < 0) 
							strDamage = strDamage + " <font color=\'#FF0000\'>(" + iDamageDelta.toString() + ")</font>";
					}
					infoCard.DamageValue.textAutoSize = "shrink";
					infoCard.DamageValue.html = true;
					infoCard.DamageValue.SetText(strDamage, true);
					break;
					
				case Inventory.ICT_POTION:
				case Inventory.ICT_FOOD:
					var EF_HEALTH: Number = 0;
					var EF_MAGICKA: Number = 1;
					var EF_STAMINA: Number = 2;
					if (a_itemUpdateObj.potionType == EF_MAGICKA) {
						infoCard.gotoAndStop("MagickaPotion");
					}
					else if (a_itemUpdateObj.potionType == EF_STAMINA) {
						infoCard.gotoAndStop("StaminaPotion");
					}
					else if (a_itemUpdateObj.potionType == EF_HEALTH) {
						infoCard.gotoAndStop("HealthPotion");
					}
					break;
					
				case Inventory.ICT_SPELL_DEFAULT:
				case Inventory.ICT_ACTIVE_EFFECT:
					infoCard.gotoAndStop("Magic");
					bHasWeightandValue = false;
					break;
					
				case Inventory.ICT_SPELL:
					infoCard.gotoAndStop("MagicSkill");
					if (a_itemUpdateObj.magicSchoolName != undefined) 
						updateSkillBar(a_itemUpdateObj.magicSchoolName, a_itemUpdateObj.magicSchoolLevel, a_itemUpdateObj.magicSchoolPct);
					bHasWeightandValue = false;
					break;
					
				case Inventory.ICT_SHOUT:
					infoCard.gotoAndStop("Shout");
					infoCard.DragonSoulTextInstance.SetText(_playerInfoObj.dragonSoulText);
					bHasWeightandValue = false;
					break;
					
				case Inventory.ICT_BOOK:
				case Inventory.ICT_INGREDIENT:
				case Inventory.ICT_MISC:
				case Inventory.ICT_KEY:
				default:
					infoCard.gotoAndStop("Default");
			}
			
			if (bHasWeightandValue) {
				infoCard.CarryWeightValue.textAutoSize = "shrink";
				infoCard.CarryWeightValue.SetText(Math.ceil(_playerInfoObj.encumbrance) + "/" + Math.floor(_playerInfoObj.maxEncumbrance));
				infoCard.PlayerGoldValue.textAutoSize = "shrink";
				infoCard.PlayerGoldValue.SetText(_playerInfoObj.gold.toString());
				infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width;
				infoCard.CarryWeightValue._x = infoCard.PlayerGoldLabel._x + infoCard.PlayerGoldLabel.getLineMetrics(0).x - infoCard.CarryWeightValue._width - 5;
				infoCard.CarryWeightLabel._x = infoCard.CarryWeightValue._x + infoCard.CarryWeightValue.getLineMetrics(0).x - infoCard.CarryWeightLabel._width;
				if (itemType === Inventory.ICT_ARMOR) {
					infoCard.ArmorRatingValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.ArmorRatingValue._width - 5;
					infoCard.ArmorRatingLabel._x = infoCard.ArmorRatingValue._x + infoCard.ArmorRatingValue.getLineMetrics(0).x - infoCard.ArmorRatingLabel._width;
					
					//Frostfall
					updateFrostfallElementPositions();

				} else if (itemType === Inventory.ICT_WEAPON) {
					infoCard.DamageValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.DamageValue._width - 5;
					infoCard.DamageLabel._x = infoCard.DamageValue._x + infoCard.DamageValue.getLineMetrics(0).x - infoCard.DamageLabel._width;
				}
			}
			updateStatMeter(infoCard.HealthRect, _healthMeter, _playerInfoObj.health, _playerInfoObj.maxHealth, _playerInfoObj.healthColor);
			updateStatMeter(infoCard.MagickaRect, _magickaMeter, _playerInfoObj.magicka, _playerInfoObj.maxMagicka, _playerInfoObj.magickaColor);
			updateStatMeter(infoCard.StaminaRect, _staminaMeter, _playerInfoObj.stamina, _playerInfoObj.maxStamina, _playerInfoObj.staminaColor);
		}
	}

	// @API
	public function UpdateCraftingInfo(a_skillName: String, a_levelStart: Number, a_levelPercent: Number): Void
	{
		playerInfoCard.gotoAndStop("Crafting");
		updateSkillBar(a_skillName, a_levelStart, a_levelPercent);
	}

	public function updateBarterInfo(a_playerUpdateObj: Object, a_itemUpdateObj: Object, a_playerGold: Number, a_vendorGold: Number, a_vendorName: String): Void
	{
		_playerInfoObj = a_playerUpdateObj;

		var infoCard = playerInfoCard;

		infoCard.gotoAndStop("Barter");

		infoCard.CarryWeightValue.textAutoSize = "shrink";
		infoCard.CarryWeightValue.SetText(Math.ceil(_playerInfoObj.encumbrance) + "/" + Math.floor(_playerInfoObj.maxEncumbrance));

		infoCard.VendorGoldLabel.textAutoSize = "shrink";
		if (a_vendorName != undefined) {
			infoCard.VendorGoldLabel.SetText("$Gold");
			infoCard.VendorGoldLabel.SetText(a_vendorName + " " + infoCard.VendorGoldLabel.text);
		}

		updateBarterPriceInfo(a_playerGold, a_vendorGold, a_itemUpdateObj);
	}

	public function updateBarterPriceInfo(a_playerGold: Number, a_vendorGold: Number, a_itemUpdateObj: Object, a_goldDelta: Number): Void
	{
		var infoCard = playerInfoCard;

		infoCard.PlayerGoldValue.textAutoSize = "shrink";
		if (a_goldDelta == undefined) {
			infoCard.PlayerGoldValue.SetText(a_playerGold.toString(), true);
		} else if (a_goldDelta >= 0) {
			infoCard.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#189515\'>(+" + a_goldDelta.toString() + ")</font>", true);
		} else {
			infoCard.PlayerGoldValue.SetText(a_playerGold.toString() + " <font color=\'#FF0000\'>(" + a_goldDelta.toString() + ")</font>", true);
		}

		infoCard.VendorGoldValue.textAutoSize = "shrink";
		infoCard.VendorGoldValue.SetText(a_vendorGold.toString());

		infoCard.VendorGoldLabel._x = infoCard.VendorGoldValue._x + infoCard.VendorGoldValue.getLineMetrics(0).x - infoCard.VendorGoldLabel._width;
		infoCard.PlayerGoldValue._x = infoCard.VendorGoldLabel._x + infoCard.VendorGoldLabel.getLineMetrics(0).x - infoCard.PlayerGoldValue._width - 10;
		infoCard.PlayerGoldLabel._x = infoCard.PlayerGoldValue._x + infoCard.PlayerGoldValue.getLineMetrics(0).x - infoCard.PlayerGoldLabel._width;
		infoCard.CarryWeightValue._x = infoCard.PlayerGoldLabel._x + infoCard.PlayerGoldLabel.getLineMetrics(0).x - infoCard.CarryWeightValue._width - 5;
		infoCard.CarryWeightLabel._x = infoCard.CarryWeightValue._x + infoCard.CarryWeightValue.getLineMetrics(0).x - infoCard.CarryWeightLabel._width;

		updateBarterPerItemInfo(a_itemUpdateObj);
	}

	public function updateBarterPerItemInfo(a_itemUpdateObj: Object): Void
	{
		var infoCard = playerInfoCard;
		var itemType: Number = a_itemUpdateObj.type;

		if (itemType == undefined) {
			itemType = _lastItemType;
			if (a_itemUpdateObj == undefined)
				a_itemUpdateObj = {type: _lastItemType};
		} else {
			_lastItemType = itemType;
		}

		if (a_itemUpdateObj != undefined) {
			var itemType: Number = a_itemUpdateObj.type;
			
			switch(itemType) {
				case Inventory.ICT_ARMOR:
					infoCard.gotoAndStop("Barter_Armor");
					var strArmor: String = Math.floor(_playerInfoObj.armor).toString();
					if (a_itemUpdateObj.armorChange != undefined) {
						var iArmorDelta: Number = Math.round(a_itemUpdateObj.armorChange);
						if (iArmorDelta > 0) 
							strArmor = strArmor + " <font color=\'#189515\'>(+" + iArmorDelta.toString() + ")</font>";
						else if (iArmorDelta < 0) 
							strArmor = strArmor + " <font color=\'#FF0000\'>(" + iArmorDelta.toString() + ")</font>";
					}
					infoCard.ArmorRatingValue.textAutoSize = "shrink";
					infoCard.ArmorRatingValue.html = true;
					infoCard.ArmorRatingValue.SetText(strArmor, true);
					infoCard.ArmorRatingValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.ArmorRatingValue._width - 5;
					infoCard.ArmorRatingLabel._x = infoCard.ArmorRatingValue._x + infoCard.ArmorRatingValue.getLineMetrics(0).x - infoCard.ArmorRatingLabel._width;
					//Frostfall
					updateFrostfallValues(a_itemUpdateObj);
					updateFrostfallElementPositions();
					break;
					
				case Inventory.ICT_WEAPON:
					infoCard.gotoAndStop("Barter_Weapon");
					var strDamage: String = Math.floor(_playerInfoObj.damage).toString();
					if (a_itemUpdateObj.damageChange != undefined) {
						var iDamageDelta: Number = Math.round(a_itemUpdateObj.damageChange);
						if (iDamageDelta > 0) 
							strDamage = strDamage + " <font color=\'#189515\'>(+" + iDamageDelta.toString() + ")</font>";
						else if (iDamageDelta < 0) 
							strDamage = strDamage + " <font color=\'#FF0000\'>(" + iDamageDelta.toString() + ")</font>";
					}
					infoCard.DamageValue.textAutoSize = "shrink";
					infoCard.DamageValue.html = true;
					infoCard.DamageValue.SetText(strDamage, true);
					infoCard.DamageValue._x = infoCard.CarryWeightLabel._x + infoCard.CarryWeightLabel.getLineMetrics(0).x - infoCard.DamageValue._width - 5;
					infoCard.DamageLabel._x = infoCard.DamageValue._x + infoCard.DamageValue.getLineMetrics(0).x - infoCard.DamageLabel._width;
					break;
					
				default:
					infoCard.gotoAndStop("Barter");
			}
		}
	}

	public function setGiftInfo(a_favorPoints: Number): Void
	{
		playerInfoCard.gotoAndStop("Gift");
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
	}

  function GoToDefaultFrame()
  {
  	// TODO! Check if the MC actually have a "default" defined
    playerInfoCard.gotoAndStop("Default");
  }

  /* PRIVATE FUNCTIONS */
	
	private function updateStatMeter(a_meterRect: MovieClip, a_meterObj: Meter, a_currValue: Number, a_maxValue: Number, a_colorStr: String): Void
	{
		if (a_colorStr == undefined) 
			a_colorStr = "#FFFFFF";
		if (a_meterRect._alpha > 0) {
			if (a_meterRect.MeterText != undefined) {
				a_meterRect.MeterText.textAutoSize = "shrink";
				a_meterRect.MeterText.html = true;
				a_meterRect.MeterText.SetText("<font color=\'" + a_colorStr + "\'>" + Math.floor(a_currValue) + "/" + Math.floor(a_maxValue) + "</font>", true);
			}
			a_meterRect.MeterInstance.gotoAndStop("Pause");
			a_meterObj.SetPercent(a_currValue / a_maxValue * 100);
		}
	}
	
	private function updateSkillBar(a_skillName: String, a_levelStart: Number, a_levelPercent: Number): Void
	{
		var infoCard = playerInfoCard;
		
		infoCard.SkillLevelLabel.SetText(a_skillName);
		infoCard.SkillLevelCurrent.SetText(a_levelStart);
		infoCard.SkillLevelNext.SetText(a_levelStart + 1);
		infoCard.LevelMeterInstance.gotoAndStop("Pause");
		_levelMeter.SetPercent(a_levelPercent);
	}

	//Frostfall
	public function updateFrostfallWarmth(warmth: Number): Void
	{
		_currentTotalWarmth = warmth;
		updateFrostfallWarmthFromStoredValues()
		updateFrostfallElementPositions();
	}

	public function updateFrostfallCoverage(coverage: Number): Void
	{
		_currentTotalCoverage = coverage;
		updateFrostfallCoverageFromStoredValues()
		updateFrostfallElementPositions();
	}

	public function updateFrostfallElementPositions(): Void
	{
		var infoCard = playerInfoCard;
		infoCard.RainProtectionValue._x = infoCard.ArmorRatingLabel._x + infoCard.ArmorRatingLabel.getLineMetrics(0).x - infoCard.RainProtectionValue._width - 5;
		infoCard.RainProtectionLabel._x = infoCard.RainProtectionValue._x + infoCard.RainProtectionValue.getLineMetrics(0).x - infoCard.RainProtectionLabel._width;
		infoCard.ExposureProtectionValue._x = infoCard.RainProtectionLabel._x + infoCard.RainProtectionLabel.getLineMetrics(0).x - infoCard.ExposureProtectionValue._width - 5;
		infoCard.ExposureProtectionLabel._x = infoCard.ExposureProtectionValue._x + infoCard.ExposureProtectionValue.getLineMetrics(0).x - infoCard.ExposureProtectionLabel._width;
	}

	public function updateFrostfallValues(a_itemUpdateObj: Object): Void
	{
		var infoCard = playerInfoCard;
		var strWarmth: String = "";  // init to empty string to support changes below
		var strCoverage: String = "";

		// Shouldn't need this, but for some reason 'undefined' is getting through
		if (_currentTotalWarmth !== undefined  && _lastWarmthDelta !== undefined) {
			strWarmth = _currentTotalWarmth.toString();
		}

		if (a_itemUpdateObj.currentArmorWarmth !== undefined) {
			var iWarmthDelta = a_itemUpdateObj.warmth - a_itemUpdateObj.currentArmorWarmth;
			if (iWarmthDelta > 0) {
				_lastWarmthDelta = " <font color=\'#189515\'>(+" + iWarmthDelta.toString() + ")</font>";
				if (_lastWarmthDelta !== undefined) {
					strWarmth = strWarmth + _lastWarmthDelta;
				}
			}
			else if (iWarmthDelta < 0) {
				_lastWarmthDelta = " <font color=\'#FF0000\'>(" + iWarmthDelta.toString() + ")</font>";
				if (_lastWarmthDelta !== undefined) {
					strWarmth = strWarmth + _lastWarmthDelta;
				}
			}
			else {
				_lastWarmthDelta = "";
				skse.Log("BottomBar - a_itemUpdateObj.warmth is " + a_itemUpdateObj.warmth + ", a_itemUpdateObj.currentArmorWarmth is " + a_itemUpdateObj.currentArmorWarmth);
				skse.Log("BottomBar - Warmth Delta is " + iWarmthDelta)
			}
		}
		infoCard.ExposureProtectionValue.textAutoSize = "shrink";
		infoCard.ExposureProtectionValue.html = true;
		infoCard.ExposureProtectionValue.SetText(strWarmth, true);

		// Shouldn't need this, but for some reason 'undefined' is getting through
		if (_currentTotalWarmth !== undefined && _lastCoverageDelta !== undefined) {
			strCoverage = _currentTotalCoverage.toString();
		}

		if (a_itemUpdateObj.currentArmorCoverage !== undefined) {
			var iCoverageDelta = a_itemUpdateObj.coverage - a_itemUpdateObj.currentArmorCoverage;
			if (iCoverageDelta > 0) {
				_lastCoverageDelta = " <font color=\'#189515\'>(+" + iCoverageDelta.toString() + ")</font>"
				if (_lastCoverageDelta !== undefined) {
					strCoverage = strCoverage + _lastCoverageDelta;
				}
			}
			else if (iCoverageDelta < 0) {
				_lastCoverageDelta = " <font color=\'#FF0000\'>(" + iCoverageDelta.toString() + ")</font>"
				if (_lastCoverageDelta !== undefined) {
					strCoverage = strCoverage + _lastCoverageDelta;
				}
			}
			else {
				_lastCoverageDelta = "";
				skse.Log("BottomBar - a_itemUpdateObj.coverage is " + a_itemUpdateObj.coverage + ", a_itemUpdateObj.currentArmorCoverage is " + a_itemUpdateObj.currentArmorCoverage);
				skse.Log("BottomBar - Coverage Delta is " + iCoverageDelta)
			}
		}
		infoCard.RainProtectionValue.textAutoSize = "shrink";
		infoCard.RainProtectionValue.html = true;
		infoCard.RainProtectionValue.SetText(strCoverage, true);
	}

	// possible culprit of '0undefined' (coverage value + undefined) showing in BottomBar
	private function updateFrostfallWarmthFromStoredValues(): Void
	{
		var infoCard = playerInfoCard;
		var strWarmth: String = "";
		
		if (_currentTotalWarmth !== undefined  && _lastWarmthDelta !== undefined) {
			strWarmth = _currentTotalWarmth.toString();
		}

		// Shouldn't need this but 'undefined' is getting through somehow
		if (_lastWarmthDelta !== undefined) {
			strWarmth = strWarmth + _lastWarmthDelta;
		}

		infoCard.ExposureProtectionValue.textAutoSize = "shrink";
		infoCard.ExposureProtectionValue.html = true;
		infoCard.ExposureProtectionValue.SetText(strWarmth, true);
	}

	// possible culprit of '0undefined' (coverage value + undefined) showing in BottomBar
	private function updateFrostfallCoverageFromStoredValues(): Void
	{
		var infoCard = playerInfoCard;		
		var strCoverage: String = "";

		if (_currentTotalWarmth !== undefined && _lastCoverageDelta !== undefined) {
			strCoverage = _currentTotalCoverage.toString();
		}

		// Shouldn't need this but 'undefined' is getting through somehow
		if (_lastCoverageDelta !== undefined) {
			strCoverage = strCoverage + _lastCoverageDelta;
		}
		infoCard.RainProtectionValue.textAutoSize = "shrink";
		infoCard.RainProtectionValue.html = true;
		infoCard.RainProtectionValue.SetText(strCoverage, true);
	}
}
