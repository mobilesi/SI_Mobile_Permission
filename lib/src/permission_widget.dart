import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWidget extends StatefulWidget {
  final Permission permission;
  final Widget deniedWidget;
  final Widget grantedWidget;
  final PermissionController? controller;
  final bool isRequestWhenInit;
  final Function? onGranted, onDenied, onPermanentlyDenied;

  const PermissionWidget(
      {Key? key,
      required this.permission,
      required this.deniedWidget,
      required this.grantedWidget,
      this.controller,
      this.isRequestWhenInit = true,
      this.onGranted,
      this.onDenied, this.onPermanentlyDenied})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PermissionWidgetState();
  }
}

class PermissionController extends ChangeNotifier {
  request() {
    notifyListeners();
  }

  openAppSetting() {
    openAppSettings();
  }
}

enum PermissionCheckTime { init, active, resume }

class _PermissionWidgetState extends State<PermissionWidget> with WidgetsBindingObserver {
  PermissionStatus? _status;

  @override
  void initState() {
    widget.controller?.addListener(_requestPermission);
    WidgetsBinding.instance.addObserver(this);
    if (widget.isRequestWhenInit == true) {
      widget.permission.request().then((value) {
        _updateStateByPermissionStatus(value, PermissionCheckTime.init);
      });
    } else {
      widget.permission.status.then((value) {
        _updateStateByPermissionStatus(value, PermissionCheckTime.init);
      });
    }
    super.initState();
  }

  _updateStateByPermissionStatus(PermissionStatus value, PermissionCheckTime checkTime, {bool hasCallback = true}) {
    if (_status == null || _status != value) {
      setState(() {
        _status = value;
      });
    }
    if (hasCallback == false) {
      return;
    }
    if (value == PermissionStatus.granted || value == PermissionStatus.limited) {
      widget.onGranted?.call(checkTime);
    } else if (value == PermissionStatus.permanentlyDenied) {
      widget.onPermanentlyDenied?.call(checkTime);
    } else {
      widget.onDenied?.call(checkTime);
    }
  }

  _requestPermission() {
    // if (Platform.isAndroid && _status == PermissionStatus.permanentlyDenied) {
    //   openAppSettings();
    //   return;
    // }
    // if (Platform.isIOS && _status == PermissionStatus.denied) {
    //   openAppSettings();
    //   return;
    // }

    // if (_status == PermissionStatus.permanentlyDenied) {
    //   openAppSettings();
    //   return;
    // }

    // widget.permission.request();

    widget.permission.request().then((value) {
      _updateStateByPermissionStatus(value, PermissionCheckTime.active);
    });
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_requestPermission);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // check permissions when app is resumed
  // this is when permissions are changed in app settings outside of app
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.permission.status.then((value) {
        _updateStateByPermissionStatus(value, PermissionCheckTime.resume, hasCallback: false);
      });
    } else if (state == AppLifecycleState.inactive) {
      // if (widget.scanController != null) {
      //   widget.scanController.stop();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return (_status != null && _status == PermissionStatus.granted) ? widget.grantedWidget : widget.deniedWidget;
  }
}
