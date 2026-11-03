# Bookstore (UIKit)

A native iOS eCommerce bookstore front end written in Swift with UIKit only. It uses no SwiftUI, storyboards or XIBs, and every screen is built in code. It runs on a mock in-memory catalog, so there is no backend.

## Run it

1. Open `Bookstore.xcodeproj` in Xcode 15 or later.
2. Pick an iPhone simulator (iOS 16+) and press **Run** (⌘R).
3. Press ⌘U to run the 25 unit tests.

To run on a physical device, select the **Bookstore** target, then **Signing & Capabilities**, and choose your Team. Change the bundle identifier `com.example.Bookstore` if needed.

## Features

- **Browse:** a bestsellers carousel plus a book grid (2 columns on iPhone, 4 on iPad), with search by title, author or genre.
- **Sort & Filter:** a sheet with radio-style sorting, filter toggles, and genre and price checkboxes. There is no price-range slider.
  - The two toggle rows ("Bestsellers" and "Highly rated") can be hidden: set `showsBestsellersToggle` or `showsHighlyRatedToggle` to `false` on `SortFilterViewController` before presenting it.
- **Book detail:** cover, synopsis and an Add to cart button.
- **Cart:** change quantities, swipe to delete, see shipping and totals. Shipping is free at $35 or more, and a badge on the tab shows the item count.
- **Checkout:** shipping form with validation, followed by an order confirmation.
- **Accessibility:** VoiceOver labels and traits are set on the custom controls.
- **Branding:** generated book cover artwork, an app icon and a launch screen live in `Bookstore/Assets.xcassets`. If a `cover_<id>` image is missing, `BookCoverView` falls back to a gradient with the title and author.

## Regenerating the artwork

`Bookstore/Assets.xcassets` is produced by `Scripts/generate_assets.swift`. Keep its catalog in sync with `MockBookRepository.sampleBooks`, then run from the repository root:

```bash
swiftc -O Scripts/generate_assets.swift -o /tmp/generate_assets && /tmp/generate_assets Bookstore/Assets.xcassets
```

## Structure

| Folder | Contents |
|---|---|
| `Bookstore/Models` | `Book`, `BookQuery` (search, filter and sort rules), `CartItem`, `Order` |
| `Bookstore/Services` | `BookRepository` (mock data), `CartStore`, `CheckoutService`, `AppContainer` |
| `Bookstore/ViewModels` | `CatalogViewModel` |
| `Bookstore/Views` | All view controllers, cells and shared components |
| `BookstoreTests` | Unit tests for querying, cart and checkout logic |

## Connecting a real backend

Implement the `BookRepository` protocol with your API client and pass it to `AppContainer(repository:)` in `SceneDelegate`. Order placement lives in `CheckoutService.placeOrder`, so replace that with a network call. Use HTTPS only, and keep API keys out of source control, for example in an `.xcconfig` that is listed in `.gitignore`.

## Regenerating the Xcode project

`Bookstore.xcodeproj` is generated from the files on disk. After adding or removing Swift files outside Xcode, run:

```bash
ruby Scripts/generate_xcodeproj.rb   # needs the `xcodeproj` gem
```
