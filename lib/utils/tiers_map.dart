getTier(String tier) {
  switch (tier) {
    case 'Up to 15':
      return 15;

    case 'Up to 5':
      return 5;

    case 'Unlimited':
      return 9999;

    default:
      return 0;
  }
}
