import 'package:ludo/controller/tokens-controller/tokens_controller.dart';
import 'package:ludo/domain/model/token.dart';

void killTokens(TokensController controller, Token targetToken) {
  List<Token> newList=List<Token>.from(controller.tokenNotifier.value);
  newList[targetToken.id-1]=targetToken.copyWith(newPathIndex: -1);
  controller.tokenNotifier.value=newList;
}
