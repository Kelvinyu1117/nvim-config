#include <iostream>
#include <vector>

int main() {
  std::vector<int> xs{1, 2, 3};
  for (int x : xs) std::cout << x << '\n';
}
