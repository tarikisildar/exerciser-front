import numpy as np
from dtw import dtw
import json
import os 
from fnmatch import fnmatch

class SimilarityChecker:

    def __init__(self, precomputed_dir):

        self.precomputed_paths = self.get_json_paths(precomputed_dir)
        self.KEYPOINT_COUNT = 17

        self.video_keypoint_arrays = {}

    def get_json_paths(self, root):

        pattern = "*.json"

        all_paths = []

        for path, subdirs, files in os.walk(root):
            for name in files:
                if fnmatch(name, pattern):
                    all_paths.append(os.path.join(path, name))

        return all_paths

    def read_json(self, path):
        
        with open(path, encoding='utf-8') as f:

            data = json.load(f)  

        return data

    def load_precomputed_hashmaps(self):

        for path in self.precomputed_paths:
            self.video_keypoint_arrays[path] = self.convert_to_hashmap(path)


    def convert_to_hashmap(self, path):

        data = self.read_json(path)
        hashmap = {}

        for offset in range(self.KEYPOINT_COUNT):
            result_x, result_y = self.convert_list_to_1d_array(data, offset)
            hashmap[offset] = {}
            hashmap[offset]["x"] = result_x
            hashmap[offset]["y"] = result_y
                
        return hashmap


    def convert_list_to_1d_array(self, array, offset=0):

        result_x = []
        result_y = []

        for ele_array in array:

            if len(ele_array) == 0:
                continue

            ele = ele_array[offset]

            x, y = ele["x"], ele["y"]

            result_x.append(x)
            result_y.append(y)

            
        return np.array(result_x).reshape(-1, 1), np.array(result_y).reshape(-1, 1)

    def compute_all_similarities(self, target_json_path):
        
        
        target_arrays = self.convert_to_hashmap(target_json_path)

        print(self.video_keypoint_arrays.keys())
        print(self.video_keypoint_arrays["D:/graduate/data\\1 - Copy\\video_random.json"].keys())


        for comp_path, comp_arr in self.video_keypoint_arrays.items():

            distance = self.compute_similarity(target_arrays, comp_arr)

            print("Computed similarity between {} and {} is {:.2f}".format(target_json_path, comp_path, 
                                                                distance))


    def compute_similarity(self, given_data, target_data):

        total_distance = 0

        # manhattan_distance = lambda x, y: np.abs(x - y)
        square_distance = lambda x, y: (x - y) ** 2
        distance_method = square_distance


        for i in range(self.KEYPOINT_COUNT):

            d, cost_matrix, acc_cost_matrix, path = dtw(given_data[i]["x"], target_data[i]["x"], dist=distance_method)
            total_distance += d


            d, cost_matrix, acc_cost_matrix, path = dtw(given_data[i]["y"], target_data[i]["y"], dist=distance_method)
            total_distance += d

        return total_distance

DATA_PRECOMPUTED = "D:/graduate/data"
DATA_PATH_2 = "D:/onurRealtimeOriginal.json"

checker = SimilarityChecker(DATA_PRECOMPUTED)
checker.load_precomputed_hashmaps()

checker.compute_all_similarities(DATA_PATH_2)

