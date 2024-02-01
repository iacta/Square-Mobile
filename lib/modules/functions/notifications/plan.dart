
String expireMessage(int day) {

  if (day == 14) {
    return 'Restam apenas 14 dias para o plano expirar.';
  } else if (day == 7) {
    return 'Restam apenas 7 dias para o plano expirar.';
  } else if (day == 3) {
    return 'Restam apenas 3 dias para o plano expirar.';
  } else if (day == 1) {
    return 'O seu plano expira amanhã!';
  } else if (day == 0) {
    return 'O plano expira hoje!';
  } else {
    return '';
  }
}



