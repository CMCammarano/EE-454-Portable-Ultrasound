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
	int RANGE;
	cout << "Enter range: "; cin >> RANGE; cout << endl;
	cout << "Enter 1 for manual input, enter any other number to generate random: " << endl; cin >> choice; cout << endl;
	// cout << "Enter filename: "; cin >> FILENAME;
	vector<string>* binaryVector = new vector<string>;
	vector<string>* decimalVector = new vector<string>;
	string FILENAME = to_string(choice) + "_points_" + to_string(RANGE) + "_range.txt";
	ofstream fout(FILENAME.c_str());

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

		for (int i = 0; i < choice; ++i){
			numA = rand() % RANGE;
			numB = rand() % RANGE;
			numStringA = convertToBinary(numA);
			numStringB = convertToBinary(numB);
			binaryVector -> push_back(numStringB + numStringA);
		}

		for (int i = 0; i < choice - binaryVector -> size(); ++i){
			fout << filler;
			if (i % 4 == 3){
			}
		}
		for (int i = 0; i < binaryVector -> size(); ++i){
			fout << binaryVector -> at(i);
			if (i % 4 == 3){
			}
		}
	}

	fout.close();
	delete decimalVector;
	delete binaryVector;

	return 0;
}