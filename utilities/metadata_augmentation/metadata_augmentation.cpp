/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <filesystem>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstdlib>
#include <ctime>

using std::string;

string augment_record(string record, time_t augment_time);
time_t random_time(time_t begin, time_t end);
unsigned int rand32();
time_t round_next_day(time_t time);

// Relative paths to input and output files from the project root
const char* input_csv_path = "/input/Chest_xray_Corona_Metadata.csv";
const char* output_csv_path = "/Chest_xray_Corona_Metadata.Augmented.csv";

const int SECONDS_PER_DAY = 86400;

int main() {
	// Use an environment variable to determine the path to project root
	const string project_root = std::getenv("CAPSTONE_ROOT");

	std::ifstream input_csv(project_root + input_csv_path);
	std::ofstream output_csv(project_root + output_csv_path);

	// Calculate begin and end range of times a record may be augmented with
	time_t now = time(nullptr);
	time_t end = round_next_day(now);
	time_t begin = end - (30 * SECONDS_PER_DAY);

	// Seed random number generator with the current time
	srand(now);

	string current_record;

	// Append "Date" column to header
	std::getline(input_csv, current_record);
	output_csv << current_record + ",Date" << std::endl;

	// Fetch, augment, and output each record from the input file
	while (std::getline(input_csv, current_record)) {
		time_t augment_time = random_time(begin, end);
		output_csv << augment_record(current_record, augment_time) << std::endl;
	}

	return 0;
}

// To round to the next day, add a day, then zero out time fields
time_t round_next_day(time_t time) {
	time_t time_plus_day = time + SECONDS_PER_DAY;
	tm* next_day = localtime(&time_plus_day);
	next_day->tm_hour = 0;
	next_day->tm_min = 0;
	next_day->tm_sec = 0;
	return mktime(next_day);
}

// Select a random time_t (aka "long long") between begin and end
time_t random_time(time_t begin, time_t end) {
	int diff_seconds = (int)difftime(end, begin);
	int random_diff = rand32() % diff_seconds;
	return begin + random_diff;
}

// We need 32 bits of randomness. rand() is only specified to return 16 bits...
unsigned int rand32() {
	unsigned int most_significant = (rand() & 0xffff) << 16;
	unsigned int least_significant = rand() & 0xffff;
	return most_significant | least_significant;
}

// Augment this record with a date field
string augment_record(string record, time_t augment_time) {
	char buffer[32];

	tm* augment_tm = localtime(&augment_time);
	std::strftime(buffer, 32, "%Y-%m-%d", augment_tm);
	return record + ',' + buffer;
}