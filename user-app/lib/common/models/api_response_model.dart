
class AptresponseModel<T> {
  final T? response;
  final dynamic error;
  final bool isSuccess;

  AptresponseModel(this.response, this.error, this.isSuccess);

  AptresponseModel.withError(dynamic errorValue) : response = null, error = errorValue, isSuccess = false;

  AptresponseModel.withSuccess(T? responseValue)
      : response = responseValue,
        error = null, isSuccess = true;
}


