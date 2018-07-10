#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <map>
#include <vector>
#include <cstring>
#include <opencv2\opencv.hpp>
#include <cmath>
#include <ctime>

using namespace std;
using namespace cv;

struct point {
	int x;
	int y;
};

struct PARAMS {
	map<string, point> msp;
	int width, top, left, height;
	double yaw_angle, pitch_angle, roll_angle;
	double r_pos_x, r_vec_z, r_vec_x, r_vec_y, r_pos_y;
	double l_pos_x, l_vec_z, l_vec_x, l_vec_y, l_pos_y;
};

vector<string> getLandmarkLabels(char file_name[] = "LANDMARKS106") {
	vector<string> vec_str;
	ifstream input_landmark_label(file_name);
	string str;
	while (input_landmark_label >> str) {
		vec_str.push_back(str);
	}
	input_landmark_label.close();
	return vec_str;
}
void curlHttpPost() {
	string strPost = "curl -X POST \"https://api-us.faceplusplus.com/facepp/v3/detect\""
		" -F \"api_key=######\""
		" -F \"api_secret=######\""
		" -F \"image_file=@temp.jpg\""
		" -F \"return_landmark=2\""
		" -F \"return_attributes=headpose,eyegaze\""
		" -m 30 > temp.dat";
	system(strPost.c_str());
}
PARAMS getFeatures() {
	ifstream input("temp.dat");
	string data;
	char cstr[1000];
	bool bf = false;

	vector<string> vec_str_landmark_labels = getLandmarkLabels();

	PARAMS pm;

	bool noFace = false;
	while (input >> data) {
		if (strstr(data.c_str(), "faces")) {
			noFace = true;
			pm.height = 0;
			pm.width = 0;
		}
		if (strstr(data.c_str(), "landmark")) {
			int sum = 0;
			while (input >> data) {
				for (int i = 0; i < vec_str_landmark_labels.size(); ++i) {
					if (strstr(data.c_str(), vec_str_landmark_labels[i].c_str())) {
						input.getline(cstr, 100, '}');
						point pt;
						sscanf_s(cstr, " {\"y\": %d, \"x\": %d", &pt.y, &pt.x);
						//cout << vec_str_landmark_labels[i] << ": " << pt.x << " " << pt.y << endl;
						pm.msp.insert(pair<string, point>(vec_str_landmark_labels[i], pt));
						sum++;
					}
				}
				if (sum >= vec_str_landmark_labels.size()) break;
			}
			cout << "sum = " << sum << endl;
		}
		if (strstr(data.c_str(), "face_rectangle")) {
			input.getline(cstr, 1000, '}');
			sscanf_s(cstr, " {\"width\": %d, \"top\" : %d, \"left\" : %d, \"height\" : %d",
				&pm.width, &pm.top, &pm.left, &pm.height);
			//cout << width << " : " << top << " " << left << endl;
		}
		if (strstr(data.c_str(), "headpose")) {
			input.getline(cstr, 1000, '}');
			sscanf_s(cstr, " {\"yaw_angle\": %lf, \"pitch_angle\": %lf, \"roll_angle\": %lf",
				&pm.yaw_angle, &pm.pitch_angle, &pm.roll_angle);
			//cout << "yaw = " << yaw_angle << " " << pitch_angle << " " << roll_angle << endl;
		}
		if (strstr(data.c_str(), "right_eye_gaze")) {
			input.getline(cstr, 1000, '}');			
			sscanf_s(cstr, " {\"position_x_coordinate\": %lf,"
				" \"vector_z_component\": %lf,"
				" \"vector_x_component\": %lf,"
				" \"vector_y_component\": %lf,"
				" \"position_y_coordinate\": %lf",
				&pm.r_pos_x, &pm.r_vec_z, &pm.r_vec_x, &pm.r_vec_y, &pm.r_pos_y);
			//cout << "right eye = " << pos_x << ends << vec_z << ends << vec_x << ends << vec_y << ends << pos_y << endl;
		}
		if (strstr(data.c_str(), "left_eye_gaze")) {
			input.getline(cstr, 1000, '}');
			sscanf_s(cstr, " {\"position_x_coordinate\": %lf,"
				" \"vector_z_component\": %lf,"
				" \"vector_x_component\": %lf,"
				" \"vector_y_component\": %lf,"
				" \"position_y_coordinate\": %lf",
				&pm.l_pos_x, &pm.l_vec_z, &pm.l_vec_x, &pm.l_vec_y, &pm.l_pos_y);
			//cout << "left eye = " << pos_x << ends << vec_z << ends << vec_x << ends << vec_y << ends << pos_y << endl;
		}
	}
	input.close();
	return pm;
}

int main() {
	cout << "This is a Face++ Application for transferring" << endl
		<< "images into bounding box data and features data." << endl;
	cout << endl << "curl.exe is needed in the current directory." << endl;
	cout << endl << "============================================================" << endl;

	string root_dir = "C:\\Users\\workspace\\Lwy\\Data4\\";

	ofstream out_feature("features4.txt", ios::app);

	srand(time(NULL));

	for (int i = 0; i < 15; ++i) {
		char dcstr[100];
		sprintf_s(dcstr, "%d000\\", i + 1);
		for (int j = 0; j < 1000; ++j) {
			/*if (i == 11 && j > 895) {
				break;
			}*/
			if (i * 1000 + j < 3211) {
				continue;
			}
			char fcstr[100];
			sprintf_s(fcstr, "frame%d.bmp", i * 1000 + j);

			string file = root_dir + string(dcstr) + string(fcstr);
			cout << file << endl;

			Mat src = imread(file.c_str());
			imwrite("temp.jpg", src);

			curlHttpPost();

			PARAMS param = getFeatures();

			if (param.height == 0 && param.width == 0) {
				out_feature << 0 << "\t" << 0 << endl;
				cout << "No Face" << endl;
				continue;
			}
			else if (param.msp.size() == 0) {
				cout << "Failed" << endl;
				j--;
				waitKey(rand() % 5000);
				continue;
			}
			

			Mat face = src(Rect(param.left, param.top, param.width, param.height));

			sprintf_s(fcstr, "FaceData4\\face%d.bmp", i * 1000 + j);
			imwrite(fcstr, face);
			Mat show = src.clone();

			rectangle(show, Rect(param.left, param.top, param.width, param.height), Scalar(0, 0, 255), 2);
			for (map<string, point>::iterator it = param.msp.begin(); it != param.msp.end(); ++it) {
				circle(show, Point(it->second.x, it->second.y), 2, Scalar(255, 0, 0), 2);
				out_feature << it->second.y << "\t" << it->second.x << "\t";
			}

			out_feature << param.yaw_angle << "\t" << param.pitch_angle << "\t" << param.roll_angle << "\t"
				<< param.r_pos_x << "\t" << param.r_vec_z << "\t" << param.r_vec_x << "\t"
				<< param.r_vec_y << "\t" << param.r_pos_y << "\t"
				<< param.l_pos_x << "\t" << param.l_vec_z << "\t" << param.l_vec_x << "\t"
				<< param.l_vec_y << "\t" << param.l_pos_y << "\t"
				<< param.left << "\t" << param.top << "\t" << param.width << "\t" << param.height << endl;

			Mat dst;
			resize(show, dst, Size(src.cols / 4, src.rows / 4));

			imshow("dst", dst);
			imshow("face", face);
			waitKey(rand() % 3000 + 3000);
			//system("pause");
		}
	}
	out_feature.close();
	return 0;
}
