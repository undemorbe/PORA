import 'package:equatable/equatable.dart';

abstract class Success extends Equatable{

  final String message;
  final dynamic data;


  const Success({required this.message,required this.data});

  @override
  List<Object?> get props => [message, data];

} 

class ServerSuccess extends Success {
  const ServerSuccess([String message = 'Успешный вызов',data ]) : super(message: message, data: data);

}

