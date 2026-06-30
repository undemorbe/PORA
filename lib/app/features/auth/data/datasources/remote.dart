import 'package:pora/app/features/auth/domain/entity/auth_types.dart';
import 'package:pora/app/internal/network/network_abstract.dart';

class NetworkOtp {
  NetworkOtp({required this.iNetworkService});

  final INetworkService iNetworkService;

  Future<Map<String,dynamic>> getOtp   ({
    required AuthTypes authType,
    required String login
  })async {

    if(authType == AuthTypes.email){
      return await _getOtpEmail(email: login);
    }else if(authType == AuthTypes.phone){
      return await  _getOtpPhone(phone: login);
    }
return {};

  }

  Future<Map<String, dynamic>> verifyOtp({required String code}) async {
    return await {};
  }

   Future<Map<String, dynamic>> _getOtpPhone({required String phone}) async {
return {};
  }

Future<Map<String, dynamic>> _getOtpEmail({required String email}) async {
return {};
  }
}