
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../connection/utils.dart';

class LoadingState{

    int? loadError;
    ScreenState? loadState = ScreenState.FINISH;
    FailState? failState;
    String? error;

    void setError(int? page) {
        loadError = page;
    }
    void setLoadingStatus(ScreenState state, ChangeNotifier changeNotifier)
    {
        loadState = state;
        changeNotifier.notifyListeners();
    }
    bool inLoading()
    {
        return loadState == ScreenState.LOADING;
    }
    bool loadingFinished()
    {
        return loadState == ScreenState.FINISH;
    }
}
