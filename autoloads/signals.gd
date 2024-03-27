extends Node

signal save
signal allPlayersReady

# settings
signal potatoPc(on : bool)

# GOAP
signal planDone
signal moveUnits(unitsToMove, oldSectio, sectio)

# Lobby
signal updatePlayers # update lobby players
signal playerJoined # play sound
signal joinedRoom # play sound
signal leftRoom # play sound
signal updateRooms
signal closedRoom
signal createdRoom # play sound
signal startGame
signal connected

# UI
signal updatePlayerStatusDone(playerId : int)
signal emitSoulsFromCollectionPosition(position : Vector2, soulsGathered : int)
signal emitSoulsFromTreasury(position : Vector2, soulsGathered : int)
signal soulReachedPlayerStats
signal soulLeftPlayerStats
signal emitFavorsFromCollectionPosition(position : Vector2, favorsGathered : int)
signal emitFavorsFromTreasury(position : Vector2, favorsGathered : int)
signal favorReachedPlayerStats
signal favorLeftPlayerStats

signal showChosenLieutenantFromAvailableLieutenantsBox(marginContainer : MarginContainer)
signal removeChosenLieutenantFromAvailableLieutenantsBox(lieutenantName : String)
signal removeChosenLieutenantFromMouse(lieutenantName : String)

signal showStartScreen
signal showArcanaCardsContainer
signal hideArcanaCardsContainer
signal showRankTrackMarginContainer

signal addArcanaCardToUi(id, cardName)
signal toogleWaitForPlayer(playerId, boolean, phase)
signal demonClicked(node)
signal returnToMainMenu
signal returnToLobby
signal menu
signal summoningDone
signal doEvilDeedsResult(playerId, demonName, favorsGathered)
signal host
signal join
signal start
signal showSectioPreview(node)
signal hideSectioPreview(sectioName)
signal showFleeControl
signal hideFleeControl
signal spinFleeArrows
signal spinFleeArrowsStopped
signal hideFleeArrow
signal showArrows(sectio : Sectio, possibleNeighbours)
signal hideArrows
signal showMessage(message)
signal hideMessage
signal pickLegions(possibleLegionsToMoveWithLieutenant, unitsAlreadyMovingWithLieutenant, capacity)
signal pickedLegions(legions)
signal confirmFlee(boolean : bool)
signal animationDone
signal help(subject)
signal tutorial(topic, text : String)
signal tutorialRead
signal showSequenceOfPlayHelp

# summoning 
signal placeUnitsFromArray

# actions
signal rankTrackEntryMouseEntered(rank : int)
signal rankTrackEntryMouseExited
signal actionsDone
signal disableActionMenuButtons
signal toggleRecruitLegionsButton(boolean)
signal toggleAvailableLieutenants(boolean : bool)
signal toggleBuyArcanaCardButton(boolean : bool)
signal toggleEndPhaseButton(boolean)
signal toggleAvailableLieutenantsCheckButtonPressed(boolean)
signal changedActionState(newState : int)

signal playerDoneWithPhase

signal deactivateArcanaCards

#signal cancelFlee
signal unitClicked(unitNode)
signal tamingHellhound
signal petitionApproved(sectioName)
signal arcanaClicked(node)
signal minorSpell(node)
signal recruitLieutenant
signal recruitLegions
signal recruiting
signal recruitingDone
signal demonDone(passAction)
signal demonDoneWithPhase(passAction)
signal passOptionSelected(passInterval : int)
signal playerDone(playerId : int)
signal changePlayerStatus
signal addPlayerStatus(playerId : int)
signal phaseDone
signal phaseReminderDone
signal triumphiratWantsToFlee(triumphirat)
signal showDoEvilDeedsControl(playerId)



signal toogleSummoningMenu(boolean : bool)

signal pickUnit(sectio)

signal createPlayerDisplayLine(playerId)
signal changePlayerDisplayValue(playerId, column, value)

signal march
signal cancelMarch

signal fleeDialog(sectioName : String, fleeFromCombat : bool)
signal forceFleeDialog

# ActionsUI to Map
signal sectiosClickable
signal sectiosUnclickable
signal demonActionDone

# ?
signal petitionsDone
signal noDemonPicked
signal demonStatusChange(demonRank, status)


# Sectios
signal sectioClicked(node)
signal neighbours(node)
signal changeSectioBackground(id, sectioPolygon)

# Camera
signal doneMoving
signal resetCamera
signal cameraResetted
signal followUnit(unit)
signal stopFollowingUnit(unit)


# arcana Cards
signal passArcanaCard
signal walkTheEarthArcanaCard

# Game
signal updateTurnTrack(turn : int)
signal actionThroughArcana(action : String)
signal action(demonRank : int, action : String)
signal resetGame
signal addPlayer(scene : Player)
signal initMouseLights
signal initSectios
signal buildCircles
signal changePlayerName(playerName)
signal addDemon(demonRank : int)
signal addDemonToUi(demon : Demon)
signal removeDemon(demonRank : int)
signal fillPickArcanaCardsContainer(cardNames)
signal addLieutenantToAvailableLieutenantsBox(lieutenantName : String)
signal petitionConfirmed
signal pickedDemonInGame(demonRank : int)
signal pickedDemon(demonRank : int)
signal pickedDemonForCombat
signal updateRankTrack(arr : Array)
signal currentDemon(rank : int)
signal doneGatheringSouls
signal proceedSignal
signal placeLieutenant(sectio, playerId, lieutenantName)
signal placeLegion(sectio, playerId)

signal unitsKilled(unitsDict)
signal unitsHit(unitsDict)
signal unitsAttack()

signal showAttackResult
signal showDefendResult
signal showUnitAttackChance
signal hideUnitAttackChance
signal showUnitDefendChance
signal hideUnitDefendChance
signal showCombatSectios
signal hideCombatSectios
signal showCombat
signal hideCombat
signal endCombat
signal hightlightCombat
signal collapseDemonCards
signal expandDemonCards(boolean)

signal toogleTameHellhoundContainer(boolean)
signal toogleBuyLieutenant(boolean)
signal populatePetitionsContainer(sectioNames)
signal win(boolean, playerId)
signal phaseReminder(phaseText)
signal phaseDescription(phaseText)
signal toggleDiscardArcanaCardControl(boolean)
signal hidePickArcanaCardContainer(cardName)
signal showSoulsSummary(soulsSummary)
signal buyArcanaCard
signal nextDemon(demonRank)
signal combatOver
signal combatPhaseStarted

signal changeSoulsInUI(playerId : int, souls : int)
signal changeSoulsInUiContainer(souls : int)


signal changeSouls(playerId : int, souls : int)
signal changeIncome(playerId : int, income : String)
signal incomeChanged(playerId : int)
signal changeFavorsInUI(playerId : int, favors : int)
signal changeFavorsInUiContainer(favors : int)
signal changeFavors(playerId : int, favors : int)
signal changeDisfavors(playerId : int, disfavors : int)
# MAP
signal skullUsed
signal removeLieutenantFromAvailableLieutenantsBox(lieutenantName)
signal recruitedLieutenant
signal spinLieutenantBox
signal spinLieutenantBoxStopped

signal spawnUnit(sectioName : String, playerId : int, unitType : Data.UnitType, unitName : String)

signal unitSelected
signal unitDeselected
# Camera
signal moveCamera(position)

signal proceed
