# Plant Tracker iOS App

**author: Josh Cook**  
**date: 2019-07-08**

![100DaysOfCodeSwift](https://img.shields.io/badge/Swift-Plant_Tracker-FA7343.svg?style=flat&logo=swift)
[![ios](https://img.shields.io/badge/iOS-Plant_Tracker-999999.svg?style=flat&logo=apple)](https://github.com/jhrcook/PlantTracker)  
[![jhc github](https://img.shields.io/badge/GitHub-jhrcook-181717.svg?style=flat&logo=github)](https://github.com/jhrcook)
[![jhc twitter](https://img.shields.io/badge/Twitter-@JoshDoesA-00aced.svg?style=flat&logo=twitter)](https://twitter.com/JoshDoesa)
[![jhc website](https://img.shields.io/badge/Website-Joshua_Cook-5087B2.svg?style=flat&logo=telegram)](https://joshuacook.netlify.com)

This is a simple iOS application to help my mom track her cacti and succulent collection. 

## Status

(updated October 1, 2019)

This app is still under development. Currently, the plant "Library" is pretty much complete. The next step will be to work on the plant "Collection" (or "Garden"?). Finally, I will add a To-Do list area with the ability to add custom push notifications.

Below is a screen recording of the plant "Library".

<img src="progress_screenshots/Aug-10-2019 08-20-06.gif" width="300"/>


## Related Resources

### Photo zoom anitated transition

I wrote-up a detailed explanation for the custom zoom animated transition used between the `ImageCollectionViewController ` and `ImagePagingCollectionViewController`. It was also implemented as a stand-alone demonstration app. Both are linked below.

[Photo Zoom Animator in iOS](https://joshuacook.netlify.com/post/photo-zoom-animator/)  
[PhotoZoomAnimator](https://github.com/jhrcook/PhotoZoomAnimator)


### Editing a row in the information table

I wrote out an explantion of the code for how I implmented the editing row system in the `LibraryDetailViewController`.
It is available as a markdown file on the GitHub repository: [Notes on implementation of drop-down multi-selection menu](https://github.com/jhrcook/PlantTracker/blob/master/EditPlantLevelManager_notes.md)


---
**External Libraries**

* [SnapKit](http://snapkit.io)
* [TwicketSegmentedControl](https://github.com/twicketapp/TwicketSegmentedControl)
* [AssetsPickerViewController](https://github.com/DragonCherry/AssetsPickerViewController)
* [Floaty](https://github.com/kciter/Floaty)
* [KeyboardObserver]()
* [TOCropViewController](https://github.com/TimOliver/TOCropViewController)
* [MultiSelectSegmentedControl](https://github.com/yonat/MultiSelectSegmentedControl)


**Assets**

The icon for the Library tab was made by [Freepik]("https://www.flaticon.com/authors/freepik") from [Flaticon](https://www.flaticon.com/) and is licensed by [Creative Commons BY 3.0](http://creativecommons.org/licenses/by/3.0/).
