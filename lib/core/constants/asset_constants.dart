/// Asset path constants for images, icons, and other assets
class AssetConstants {
  AssetConstants._();

  // Base Paths
  static const String _imagesPath = 'assets/images';
  static const String _iconsPath = 'assets/icons';
  static const String _lottiePath = 'assets/lottie';
  static const String _fontsPath = 'assets/fonts';

  // Logo & Branding
  static const String logo = '$_imagesPath/logo.png';
  static const String logoLight = '$_imagesPath/logo_light.png';
  static const String logoDark = '$_imagesPath/logo_dark.png';
  static const String appIcon = '$_imagesPath/app_icon.png';
  static const String splash = '$_imagesPath/splash.png';

  // Illustrations
  static const String emptyState = '$_imagesPath/empty_state.png';
  static const String error = '$_imagesPath/error.png';
  static const String noInternet = '$_imagesPath/no_internet.png';
  static const String success = '$_imagesPath/success.png';
  static const String noData = '$_imagesPath/no_data.png';
  static const String claimSubmitted = '$_imagesPath/claim_submitted.png';
  static const String claimApproved = '$_imagesPath/claim_approved.png';

  // Placeholder Images
  static const String placeholder = '$_imagesPath/placeholder.png';
  static const String userPlaceholder = '$_imagesPath/user_placeholder.png';
  static const String documentPlaceholder = '$_imagesPath/document_placeholder.png';

  // Icons (Custom SVG/PNG icons)
  static const String claimIcon = '$_iconsPath/claim.svg';
  static const String billIcon = '$_iconsPath/bill.svg';
  static const String advanceIcon = '$_iconsPath/advance.svg';
  static const String settlementIcon = '$_iconsPath/settlement.svg';
  static const String dashboardIcon = '$_iconsPath/dashboard.svg';
  static const String profileIcon = '$_iconsPath/profile.svg';
  static const String settingsIcon = '$_iconsPath/settings.svg';
  static const String notificationIcon = '$_iconsPath/notification.svg';
  static const String uploadIcon = '$_iconsPath/upload.svg';
  static const String downloadIcon = '$_iconsPath/download.svg';
  static const String cameraIcon = '$_iconsPath/camera.svg';
  static const String galleryIcon = '$_iconsPath/gallery.svg';
  static const String pdfIcon = '$_iconsPath/pdf.svg';
  static const String docIcon = '$_iconsPath/doc.svg';
  static const String excelIcon = '$_iconsPath/excel.svg';

  // Lottie Animations
  static const String loadingAnimation = '$_lottiePath/loading.json';
  static const String successAnimation = '$_lottiePath/success.json';
  static const String errorAnimation = '$_lottiePath/error.json';
  static const String emptyAnimation = '$_lottiePath/empty.json';
  static const String uploadAnimation = '$_lottiePath/upload.json';

  // Fonts
  static const String poppinsFont = '$_fontsPath/Poppins';
  static const String poppinsRegular = '$_fontsPath/Poppins-Regular.ttf';
  static const String poppinsMedium = '$_fontsPath/Poppins-Medium.ttf';
  static const String poppinsSemiBold = '$_fontsPath/Poppins-SemiBold.ttf';
  static const String poppinsBold = '$_fontsPath/Poppins-Bold.ttf';

  // Helper method to get file type icon
  static String getFileTypeIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return pdfIcon;
      case 'doc':
      case 'docx':
        return docIcon;
      case 'xls':
      case 'xlsx':
        return excelIcon;
      default:
        return documentPlaceholder;
    }
  }
}
