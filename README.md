# MVVMKit

## Background
`MVC` as Massive View Controller. Navigation logic scattered around Storyboard, prepareForSegue: and "plain code" approach.

## Goal
Implement a `MVVM` library that works together with `UIKit` and has the following features:

- Provides a way to describe navigation flow programmatically.
- Such description should not be placed all over the UI implementation.
- Type safe.
- Way to bind `View Model` to `View`.
- Moves decision about when and where transitions shold occur to `View Model`s.
- Integrates with `Storyboard`.
- Binds collections of `View Model`s to `UITableView`, `UICollectionView`, etc.
- Allows to test `View Model`s without `View` layers.
- Reduce boilerplate code usual for `UIKit`: registration of table cells, loading view controllers from storyboard, etc.

## Benefits
View layer (`View` + `UIViewController`) no more contains "semi-UI semi-Model" logic. Easier to write functional tests.
You can describe how to instantiate `UIView` or `UIViewController` (by initializer, from `Storyboard` or `Nib`) and provide additional information like `Reuse Identifier`s. More importantly `MVVMKit` using it to setup `View`s for you.

## Documentation

Not ready yet. Please, see example project [DLife](https://github.com/HeMet/DLife).
