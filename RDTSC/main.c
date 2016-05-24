#include <stdio.h>

long long unsigned int func(int param);

int main() {
	
	printf("\nRDTSCP\t%llu\nRDTSC\t%llu\nCPUID\t%llu\n\n", func(0), func(-1), func(1));

	return 0;
}
