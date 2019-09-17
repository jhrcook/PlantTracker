# Notes on implementation of drop-down multi-selection menu

[![ios](https://img.shields.io/badge/iOS-Plant_Tracker-999999.svg?style=flat&logo=apple)](https://github.com/jhrcook/PlantTracker)  

author: Joshua Cook  
date: 2019-09-12

**Table of Contents**

  1. [Introduction](#Introduction):
    2. [Overview](#Overview)
    3. [Demo](#Demo)
  2. [Problem](#Problem) 
  3. [Solution](#Solution)
  4. [Implementation Details](#Implementation-Details)
    1. [Questions](#Questions)
    2. [The files involved](#The-files-invovled)
    3. [The `GeneralPlantInformationTableViewController`](#the-GeneralPlantInformationTableViewController)
    4. [The `EditPlantLevelManager`](#the-editPlantLevelManager)

## Introduction

### Overview

The Plant Tracker app is my pet-project that I created because I want to get started learning iOS development.
It's purpose is to help my mom take care of her plants (mainly succulents and cacti).
I am still working on the first tab, "Library," which will contain information on all of the types of plants that she has possessed or come across at nurseries.
The first view of the Library is a table view with a row for each plant.
Selecting a plant takes the user to the detail view for the plant, a custom view with a main header images and a information panel that has three sub-views: a general information view (in progress), notes view (functional), and a view with links (to-do).
The general information view is another table view with each row showing a specific property of the plant.
The first two are the names of the plant, scientific and common names, and the rest are pre-determined types (enumerations in Swift).
The system I have implemented for the UI for editing the plant's properties in this latter group is the focus of this page.

### Demo

From the Library tab, the user enters the detail view for a single plant.
Within this table view, they want to edit some of the plant's attributes.
First, they want to edit the common name of the plant, opening up an alert controller with a text field.
The same would happen if they wanted to edit the scientific name, as well.

The next few selections, however, are of plant attributes that have pre-defined constraints on their values.
For example, the "Growing Season" can only be selected from the seasons of the year. 
Therefore, a new row is inserted with the relevant options available to select from (multi-selections are allowed for all but "Difficulty").
Selecting another row to edit closes any other editing row and opens a new one for the new selection.
As shown at the end, tapping on the same plant property that is being edited removes the editing row.

<img src="progress_screenshots/plantLevelEditingDemo.gif" width = "300" />


## Problem

The problem I encountered was how to let the user change the general information for a plant.
The name properties were simple: tapping on them brings up an alert controller with a place for text input.
I could not, however, figure out a good way of letting a user tap on the other proprties and be able to select from a predetermined list of options.


## Solution

Leo (🦸🏻‍♂️) suggested the following solution: when the user taps on a cell, another appears below it with the available options.
For example, the [Overcast](https://apps.apple.com/us/app/overcast/id888422857) app has the following feature when a podcast episode is selected:

<img src="misc/overcast_row_adding_mech.gif" width = "300" \>


## Implementation Details

While the app in general is lacking documentation, I have done my best to comment the files directly involved in this process.
Before the explanation of the current system, I ask a few questions about a few things I think can be improved, but I'm not sure how to do it.
The answers to these questions are probably too long/complicated to be written out, so we can just talk about them at the next meet-up, if that's easier.
I then begin the explanation below by enumerating the relevant files.
I then focus in on just two of them, the controller for the table view and the manager for the editing cell.
In general, I included the relevant code chunk below the text describing it.

### Questions

1. I have a lot of switch statements that switch on an `enum` for the plant property being edited in order to decide which propery of the plant object to update. Is there a way of avoiding all of these switch statements?
2. I create a new cell each time a row is tapped to edit (I explain why I did this, below). Do you think this is okay to do or do you have a better solution to try? Also, how can I check to see if this causes a memory leak?


### The files involved

* The table view controller for the general information of the plant is in the file `PlantTracker/Controllers/GeneralPlantInformationTableViewController.swift`.
* The view for this controller is a standard `UITableView` in `PlantTracker/Views/LibraryDetailView.swift`.
* The view for the cells that hold the information are in `PlantTracker/Views/GeneralInformtationTableViewCell.swift`.
* The view for the editing cell (the one that drops down when another cell is tapped) is in `PlantTracker/Views/EditingTableViewCell.swift`.
* The manager for the editing cell is a class called `EditPlantLevelManager` located in `PlantTracker/Models/EditPlantLevelManager.swift`.

### The `GeneralPlantInformationTableViewController`

The `enum PlantInformationIndex` at the top of the file just holds the order that the plant's information should be displayed in the table view.

The table view controller has a `plant: Plant` object to display the information of, and a `plantsManager` that is responsible for various app-wide duties such as saving the plant information to disk when a change is made.
The `editManager` is reponsible for handling the row for changing plant information.

```swift
/// The plant object for the general information table view
var plant: Plant!

/// The `PlantsManager` delegate that handles tasks such as saving the plants
/// if any information is edited
var plantsManager: PlantsManager!

/// Delegate to handle the editing row for collection type information
var editManager: EditPlantLevelManager?
```

The `setupViewController()` function is really more of a lazy `init()` function.
It is called by the parent view controller, `LibraryDetailViewController()`, right after being initiailized.
It makes itself the delegate for its table view then creates the `editManager` with the default `plantLevel: .difficultyLevel`.
As discussed later, the `plantLevel` of `editManager` lets the edit manager know what options to provide for the user to select and which property of the `plant` to change.
The `plantsManager` is shared so that the edit manager can save changes to the plant, too.
The final delegate assignment is just a way of communicating between this view controller and the edit manager (it is defined by a protocol with one function that is not currently used for anything, though).

```swift
/// Prepares the view controller by setting it as the delegate for the table view
/// and organizing the row editing manager and cell
func setupViewController() {
	tableView.delegate = self
	tableView.dataSource = self
	
	editManager = EditPlantLevelManager(plant: plant, plantLevel: .difficultyLevel)
	editManager?.plantsManager = self.plantsManager
	editManager?.parentTableViewDelegate = self
}
```
The number of rows for the table view is just the number of pieces of information to show (which is the number of values in the `enum PlantInformationIndex`). The number is increased by one if the editing row is being shown to the user.

```swift
override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	let count = PlantInformationIndex.count
	return editManager?.editingRowIndex == nil ? count : count + 1
}
```
The `tableView(_:cellForRowAt:)` function consists of two if-else statements.
The first checks if the editing row is present using `if let editingIndex = editManager?.editingRowIndex`.
If it is not, then the normal cell information is added using the function `addGeneralInformation(toCell:forIndexPathRow:)`.
If the editing row is available, then the second if-else statement is invoked to account for it disrupting the indexing of the other rows:

1. if the requested row is above the editing row (in the vertical table view), then the index need not be adjusted
2. if the requested row *is* the editing row, then the editing cell (held by the editing manager) is returned
3. else, the requested row is below the editing row and the `indexPath.row` must be decremented by 1 to get the correct information

```swift
override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	if let editingIndex = editManager?.editingRowIndex {
		if indexPath.row < editingIndex {
			var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
			addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row)
			return cell
		} else if indexPath.row == editingIndex {
			return editManager!.editingCell!
		} else {
			var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
			addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row - 1)
			return cell
		}
	} else {
		var cell = tableView.dequeueReusableCell(withIdentifier: "generalInfoCell", for: indexPath)
		addGeneralInformation(toCell: &cell, forIndexPathRow: indexPath.row)
		return cell
	}
}
```

The `tableView(_:didSelectRowAt:)` function is a bit more complex.
It begins by using a switch statement to check if a name property is being edited.
If so, a standard `UIAlertController` is presented to gather user input.
Its implementation is fairly standard and in the `getNewName(for:)` function.

The second part of this function handles the case where a user taps a cell containing a property of the plant that has pre-defined constraints. All of this is wrapped in [`tableView.performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil)`](https://developer.apple.com/documentation/uikit/uitableview/2887515-performbatchupdates).
There are three possible scenarios when a user taps on one of these cells:

1. there currently is no editing row presented
2. the user selects the row that the editing row is referring to (ie. the one above it)
3. the editing row is presented and the user selects a different row to edit

These three scenarios are addressed in an if-else statement in the above order.

1. If no editing cell is being shown, then the `editManager.plantLevel` is updated by setting its row index, its `plantLevel` is updated, and it is given the `UILabel` from the cell it is "editing" so it can change the text to reflect user input. Finally, the editing cell is inserted below the cell that was tapped.
2. If the user taps on the cell of the property being edited, then the editing row is deleted.
3. If the user taps on another plant property to edit, then the editing cell is first removed at its original index and then inserted at the new index. Keep in mind that `performBatchUpdates()` first does the removals, *then* the insertions. Therefore, the index for the insertion must be in reference to the state of the table *after* the deletions have been completed.

The completion handler is just used for logging.

```swift
override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
	os_log("selected row %d", log: Log.detailLibraryGeneralInfoVC, type: .info, indexPath.row)
	
	// if the rows for plant names are selected, a alert controller with
	// a text field is used to get the text input
	switch indexPath.row {
	case PlantInformationIndex.scientificName.rawValue:
		getNewName(for: .scientificName)
		return
	case PlantInformationIndex.commonName.rawValue:
		getNewName(for: .commonName)
		return
	default:
		// a row with a name value was not selected --> continue with the rest of the method
		break
	}
        
	// update the table view for selection of a row with a plant level
	// defined by a collection of pre-determined values (eg. a season of
	// the year)
	tableView.performBatchUpdates({
		if self.editManager?.editingRowIndex == nil {   // ADD editing row
			// update edit manager
			editManager?.editingRowIndex = indexPath.row + 1
			editManager?.plantLevel = getPlantLevel(forRow: indexPath.row)
			editManager?.detailLabelOfCellBeingEdited = tableView.cellForRow(at: indexPath)?.detailTextLabel
			// insert the new row
			let newEditingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
			tableView.insertRows(at: [newEditingIndexPath], with: .top)
                
		} else if editManager!.editingRowIndex! - 1 == indexPath.row {   // REMOVE editing row
			// update edit manager
			let editingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
			editManager?.editingRowIndex = nil
			editManager?.detailLabelOfCellBeingEdited = nil
			// remove the cell from the table view
			tableView.deleteRows(at: [editingIndexPath], with: .top)
                
		} else {   // "MOVE" (delete and re-insert) editing row
			// delete the current editing cell
			let editingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
			tableView.deleteRows(at: [editingIndexPath], with: .top)

			// figure out the index path indeces after removing the editing row
			let originalIndexOfSelectedRow = editManager!.editingRowIndex! < indexPath.row ? indexPath.row - 1 : indexPath.row
			editManager?.editingRowIndex = originalIndexOfSelectedRow + 1
                
			// configure editing manager for new plant level
			editManager!.plantLevel = getPlantLevel(forRow: originalIndexOfSelectedRow)
			editManager?.detailLabelOfCellBeingEdited = tableView.cellForRow(at: IndexPath(item: indexPath.row, section: 0))?.detailTextLabel
			let newEditingIndexPath = IndexPath(item: editManager!.editingRowIndex!, section: 0)
			tableView.insertRows(at: [newEditingIndexPath], with: .top)
                
		}
	}, completion: { [weak self] _ in
		os_log("Completed update of table view for the selection plant level to edit.\n\tselected index: %d\n\tediting index: %d",
				log: Log.detailLibraryGeneralInfoVC, type: .info,
				indexPath.row, self?.editManager?.editingRowIndex ?? -1)
	})
}
```

### The `EditPlantLevelManager`

The protocol `ParentTableViewDelegate` is meant to help with communication with the `EditPlantLevelManager` and the table view controller that owns it, but the one function it defines is not currently in use.

As described previously, the editing manager is passed the `plant`, the `PlantsManager`, and a `parentTableViewDelegate`.
The `PlantLevel` enum restricts the possible values that can be assigned to the manager to edit to the relevant plant properties.
The `plantLevel` property has the type `PlantLevel` and, when set, causes the manager to reset the main arrays of the editing manager and the table view cell it presents to the user.

```swift
/// The plant object to be edited
unowned var plant: Plant

/// The plants manager to handle global operations on the plants
/// such as writing changes to disk
unowned var plantsManager: PlantsManager?

/// A delegate to link the editing manager to the table view controller that
/// owns it.
var parentTableViewDelegate: ParentTableViewDelegate?

/// The various levels of the plant that can be changed
enum PlantLevel: String {
	case growingSeason = "Growing Season"
	case difficultyLevel = "Difficulty Level"
	case dormantSeason = "Dormant Season"
	case wateringLevel = "Watering Level"
	case lightingLevel = "Lighting Level"
}

/*
 The plant level that is being operated on.

 Whe it is set, this causes a "reset" for the manager by having it set
 the `allItems` array, the `plantItems` array, and making a new editing
 cell.
*/
var plantLevel: PlantLevel? {
	didSet {
		os_log("plant level of edit manager was set: %@", log: Log.editPlantManager, type: .info, plantLevel?.rawValue ?? "NIL")
		setAllItems()
		setPlantItems()
		setupEditingCell()
	}
}

/*
 All of the cases for the plant level being edited.
     
 For example, if `plantLevel` is `PlantLevel.dormantSeason`, then `allCases`
 holds all of the possible values in the `Season` enum.
*/
var allCases: [Any]?
    
/*
 All of the raw values (as `String`s) from the cases in `allCases`.
     
 For example, if `plantLevel` is `PlantLevel.dormantSeason`, then `allItems`
 holds all of the possible raw values in the `Season` enum.
*/
var allItems: [String]?
    
/*
 The values from `allItems` that are selected for the `plant` object.
     
 For example, if `plantLevel` is `PlantLevel.dormantSeason`, then
 `plantItems`holds the raw values of the cases of the `Season` enum for
 which the plant is dormant. The values will be already selected in the
 segmented controller.
*/
var plantItems: [String]?
```

The `setAllItems()` function sets the values for `allCases` and `allItems` depending on the `plantLevel`.
The `setPlantItems()` sets the `plantItems` array to hold the values that of `allCases` that are selected for the `plant` object.
These are fairly straightforward functions, so I did not transcribe them here.

The `setupEditingCell()` function creates the editing cell and organizes its segmented controller. **A new cell is created every time the `plantLevel` is changed.** I found this necessary for the batch update - if I tried to simply change the cell's index after adjusting the segmented controller, it caused some weird UI issues. The segmented controller (actually a `MultiSelectSegmentedControl` from the [MultiSelectSegmentedControl](https://github.com/yonat/MultiSelectSegmentedControl) library) is set up by assigning the editing manager as the delegate and setting the options for the user, pre-selecting those that should be selected already.

```swift
/// Prepare the cell to present to the user with a segmented controller
/// containing the options to be selected.
private func setupEditingCell() {
	editingCell = EditingTableViewCell(style: .default, reuseIdentifier: nil, items: allItems ?? [Any]())
	editingCell?.segmentedControl.delegate = self
	setUpEditingCellSegmentedControllerItems()
}

/// Prepare the segmented controller for the editing cell.
private func setUpEditingCellSegmentedControllerItems() {
	guard let cell = editingCell else { return }
	cell.segmentedControl.allowsMultipleSelection = plantLevel != .difficultyLevel
	cell.segmentedControl.selectedSegmentIndexes = indexesToSelect(forSegmentedController: cell.segmentedControl)
	cell.segmentedControl.reloadInputViews()
}
```

When a user makes a selection in the segmented controller, the `multiSelect(_:didChange:at)` function responds and saves the changes to `plant` and updates the label of the table view cell showing the plant's information (the `detailLabelOfCellBeingEdited: UILabel?` property in the editing manager).

The function has three steps:

1. Get the selected values: iterating over the possible cases and the segmented controller's index of selected cases, `selectedCases` is populated with the values currently selected in the segmented controller.
2. Set the appropriate value for the plant: switching on the `self.plantLevel` determines which property of the plant to update.
3. The `plantsManager` is asked to save the changes and the `parentTableViewDelegate` is notified that a change occurred (does not currently do anything).

```swift
func multiSelect(_ multiSelectSegmentedControl: MultiSelectSegmentedControl, didChange value: Bool, at index: Int) {
	os_log("User selected an item; total number of values selected %d.", log: Log.editPlantManager, type: .info, multiSelectSegmentedControl.selectedSegmentIndexes.count)
        
	// The cases of `allCases` that are selected in the segmented controller
	var selectedCases = [Any]()
	if let allCases = allCases {
		for index in multiSelectSegmentedControl.selectedSegmentIndexes {
			selectedCases.append(allCases[index])
		}
	}
        
	// Update the plant
	if let plantLevel = plantLevel {
		switch plantLevel {
		case .growingSeason:
			plant.growingSeason = selectedCases as? [Season] ?? [Season]()
			detailLabelOfCellBeingEdited?.text = plant.printableGrowingSeason()
		case .dormantSeason:
			plant.dormantSeason = selectedCases as? [Season] ?? [Season]()
			detailLabelOfCellBeingEdited?.text = plant.printableDormantSeason()
		case .difficultyLevel:
			if multiSelectSegmentedControl.selectedSegmentIndexes.count > 0 {
				let startIndex = multiSelectSegmentedControl.selectedSegmentIndexes.startIndex
				plant.difficulty = allCases?[multiSelectSegmentedControl.selectedSegmentIndexes[startIndex]] as? DifficultyLevel
			} else {
				plant.difficulty = nil
			}
			detailLabelOfCellBeingEdited?.text = plant.difficulty?.rawValue ?? ""
		case .wateringLevel:
			plant.watering = selectedCases as? [WateringLevel] ?? [WateringLevel]()
			detailLabelOfCellBeingEdited?.text = plant.printableWatering()
		case .lightingLevel:
			plant.lighting = selectedCases as? [LightLevel] ?? [LightLevel]()
			detailLabelOfCellBeingEdited?.text = plant.printableLighting()
		}
	}
        
	// use the `plantsManager` to save the changes to the plant
	if let delegate = plantsManager {
		os_log("Saving plants after changing levels.", log: Log.editPlantManager, type: .info)
		delegate.savePlants()
	}
        
	// Notify the parent view controller of the change
	if let delegate = parentTableViewDelegate {
		os_log("Notifying the parent view controller of the change in plant level.", log: Log.editPlantManager, type: .info)
		delegate.plantLevelDidChange()
	}
}
```
