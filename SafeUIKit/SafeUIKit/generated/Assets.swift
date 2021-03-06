// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

#if os(OSX)
  import AppKit.NSImage
  typealias AssetColorTypeAlias = NSColor
  typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
  import UIKit.UIImage
  typealias AssetColorTypeAlias = UIColor
  typealias Image = UIImage
#endif

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

@available(*, deprecated, renamed: "ImageAsset")
typealias AssetType = ImageAsset

struct ImageAsset {
  fileprivate var name: String

  var image: Image {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    let image = bundle.image(forResource: NSImage.Name(name))
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else { fatalError("Unable to load image named \(name).") }
    return result
  }
}

struct ColorAsset {
  fileprivate var name: String

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  var color: AssetColorTypeAlias {
    return AssetColorTypeAlias(asset: self)
  }
}

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
enum Asset {
  enum AddressInput {
    static let addressIconTmp = ImageAsset(name: "address-icon-tmp")
  }
  static let backgroundDarkImage = ImageAsset(name: "background-dark-image")
  static let backgroundImage = ImageAsset(name: "background-image")
  enum BrowserExtension {
    static let awaiting = ImageAsset(name: "awaiting")
    static let rejected = ImageAsset(name: "rejected")
  }
  static let checkmarkNormal = ImageAsset(name: "checkmark-normal")
  static let checkmarkSelected = ImageAsset(name: "checkmark-selected")
  static let closeIcon = ImageAsset(name: "close-icon")
  static let error = ImageAsset(name: "error")
  static let qrCode = ImageAsset(name: "qr-code")
  static let shareLink = ImageAsset(name: "share-link")
  enum TextInputs {
    static let clearIcon = ImageAsset(name: "clear-icon")
    static let defaultIcon = ImageAsset(name: "default-icon")
    static let errorIcon = ImageAsset(name: "error-icon")
    static let successIcon = ImageAsset(name: "success-icon")
  }
  enum TokenIcons {
    static let eth = ImageAsset(name: "ETH")
    static let defaultToken = ImageAsset(name: "default-token")
  }
  enum TransferView {
    static let arrowDown = ImageAsset(name: "arrow-down")
  }

  // swiftlint:disable trailing_comma
  static let allColors: [ColorAsset] = [
  ]
  static let allImages: [ImageAsset] = [
    AddressInput.addressIconTmp,
    backgroundDarkImage,
    backgroundImage,
    BrowserExtension.awaiting,
    BrowserExtension.rejected,
    checkmarkNormal,
    checkmarkSelected,
    closeIcon,
    error,
    qrCode,
    shareLink,
    TextInputs.clearIcon,
    TextInputs.defaultIcon,
    TextInputs.errorIcon,
    TextInputs.successIcon,
    TokenIcons.eth,
    TokenIcons.defaultToken,
    TransferView.arrowDown,
  ]
  // swiftlint:enable trailing_comma
  @available(*, deprecated, renamed: "allImages")
  static let allValues: [AssetType] = allImages
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

extension Image {
  @available(iOS 1.0, tvOS 1.0, watchOS 1.0, *)
  @available(OSX, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init!(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = Bundle(for: BundleToken.self)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

extension AssetColorTypeAlias {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, OSX 10.13, *)
  convenience init!(asset: ColorAsset) {
    let bundle = Bundle(for: BundleToken.self)
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(OSX)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

private final class BundleToken {}
