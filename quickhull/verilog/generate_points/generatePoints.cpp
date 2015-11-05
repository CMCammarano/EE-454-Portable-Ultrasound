#include <iostream>
#include <fstream>
#include <vector>
#include <stdlib.h>
#include <time.h>

using namespace std;
//g++-4.8 -std=c++11 generatePoints.cpp

string convertToBinary(int num){
	string binary = "";
	while (num != 0) {
		if (num % 2 == 0){
			binary = "0" + binary;
		}
		else {
			binary = "1" + binary;
		}
		num = num / 2;
	}

	while (binary.size() != 8){
		binary = "0" + binary;
	}

	return binary;
}

int main(){

	int choice = 0;
	cout << "Enter 1 for manual input, enter any other number to generate random: " << endl; cin >> choice; cout << endl;
	vector<string>* binaryVector = new vector<string>;
	vector<string>* decimalVector = new vector<string>;
	ofstream fout("points.txt");

	string filler = "0000000000000000";


		if (choice == 1){

		//each point is 16 bits, two 8 bit dimensions

		int numA = 0;
		int numB = 0;
		string numStringA;
		string numStringB;

		int count = 0;
		while(true){
			cout << "Enter X coordinate: ";
			cin >> numA;
			if (numA == -1) break;
			numStringA = convertToBinary(numA);
			
			cout << "Enter Y coordinate: ";
			cin >> numB;
			if (numB == -1) break;
			numStringB = convertToBinary(numB);

			binaryVector -> push_back(numStringB + numStringA);
			decimalVector -> push_back("(" + to_string(numA) + "," + to_string(numB) + ")");

			++count;
		}


		fout << "--- Points ---" << endl;
		for (int i = 0; i < decimalVector -> size(); ++i){
			fout << decimalVector -> at(i) << "  ";
			if (i % 8 == 7){
				fout << endl;
			}
		}

		fout << endl << "--- Binary ---" << endl;
		for (int i = 0; i < 256 - binaryVector -> size(); ++i){
			fout << filler;
			if (i % 4 == 3){
				fout << endl;
			}
		}
		fout << endl;

		for (int i = 0; i < binaryVector -> size(); ++i){
			fout << binaryVector -> at(i);
			if (i % 4 == 3){
				fout << endl;
			}
		}

	}
	else{
		srand (time(NULL));
		int numA;
		int numB;
		string numStringA;
		string numStringB;
		vector<string>* schemeVector = new vector<string>;

		for (int i = 0; i < choice; ++i){
			numA = rand() % 256;
			numB = rand() % 256;
			numStringA = convertToBinary(numA);
			numStringB = convertToBinary(numB);
			binaryVector -> push_back(numStringB + numStringA);
			decimalVector -> push_back("(" + to_string(numA) + "," + to_string(numB) + ")");
			schemeVector -> push_back("(make-point " + to_string(numA) + " " + to_string(numB) + ")");
		}

		fout << "--- Points ---" << endl;
		for (int i = 0; i < decimalVector -> size(); ++i){
			fout << decimalVector -> at(i) << "  ";
			if (i % 8 == 7){
				fout << endl;
			}
		}

		fout << endl << "--- Scheme --- " << endl;
		fout << "(define points (list" << endl;
		for (int i = 0; i < decimalVector -> size(); ++i){
			fout << schemeVector -> at(i) + " ";
			if (i % 16 == 15){
				fout << endl;
			}
		}
		fout << "))" << endl;

		fout << endl << "--- Binary ---" << endl;
		fout << endl;
		for (int i = 0; i < 256 - binaryVector -> size(); ++i){
			fout << filler;
			if (i % 4 == 3){
				fout << endl;
			}
		}
		fout << endl;
		for (int i = 0; i < binaryVector -> size(); ++i){
			fout << binaryVector -> at(i);
			if (i % 4 == 3){
				fout << endl;
			}
		}
	}

	fout.close();
	delete decimalVector;
	delete binaryVector;

	return 0;
}