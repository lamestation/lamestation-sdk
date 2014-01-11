#include <iostream>
#include <fstream>
#include <string>

using namespace std;

// This program converts the CSV BOM to a LaTeX table.
int main (int argc, char * argv[]) {

    if (argv[1] != NULL) {

        ifstream file;
        ofstream file2;
        string filename = argv[1];
        filename += ".csv";
        string filename2 = argv[1];
        filename2 += ".tex";

        file.open(filename.c_str());
        file2.open(filename2.c_str());
        char text;
        char quote_on = 0;


        if (file.is_open() && file2.is_open()) {

            while (!file.eof()) {
                text = file.get();
                if (text == '"') {
                    if (quote_on)
                        quote_on = 0;
                    else
                        quote_on = 1;
                }
                else if (text == '$') {
                    cout << "\\$";
                    file2 << "\\$";
                }
                else if (text == ',') {
                    if (!quote_on) {
                        cout << " & ";
                        file2 << " & ";
                    } else {
                        cout << text;
                        file2 << text;
                    }
                }
                else if (text == '\n') {
                    cout << " \\\\\n";
                    file2 << " \\\\\n";
                }
                else {
                    cout << text;
                    file2 << text;
                }
            }

            file.close();
            file2.close();

        } else {
            cout << "File(s) failed to open!";
            if (file.is_open()) file.close();
            if (file2.is_open()) file2.close();
            return 1;
        }

    } else {
        cout << "\nSorry, but don't know where your file is!";
        return 1;
    }

    return 0;
}
