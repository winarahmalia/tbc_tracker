void main() {
  var data = {'email': 'new@new.com'};
  var result = {
    'email': 'old@old.com',
    ...data,
  };
  print(result);
}
