#!/bin/bash

# List of subject directories
subject_numbers=(301 302 304 305 307 308 310 309 311 312)
age_categories=(0 0 0 0 1 1 1 0 1 1)
# List of run numbers
run_numbers=("perceptionLabels_run1" "perceptionLabels_run2" "perceptionNolabels_run1" "perceptionNolabels_run2" 
"recall_run1" "recall_run2")

output_csv="QA_results.csv"

echo "Subject ID,is Old,Run Number,Largest Value,Percentage over 0.5" > "$output_csv" 

for i in "${!subject_numbers[@]}"; do
    subject_number="${subject_numbers[i]}"
    age_category="${age_categories[i]}"

    # Loop through each run number
    for run in "${run_numbers[@]}"; do
        # Construct the path to the text file
        file_path="/home/kkimura/Data2/katzer3/sub-$subject_number/func/prepro/QA_$run/fd.txt"
         
        # Check if the file exists
        if [ -f "$file_path" ]; then

		# get the max volume

                    values=($(cat "$file_path"))
                    largest_value=$(printf '%s\n' "${values[@]}" | sort -n | tail -n 1)

            # Use awk to count items larger than 0.5 in the text file
            total_items=$(wc -l < "$file_path")
            items_gt_half=$(awk -v count=0 '$1 > 0.5 { count++ } END { print count }' "$file_path")
            
            # Calculate percentage
            if [ "$total_items" -gt 0 ]; then
                percentage=$(echo "scale=2; ($items_gt_half / $total_items) * 100" | bc -l)
            else
                percentage=0
            fi
fi            
# Write CSV header

# Append data to CSV
echo "$subject_number,$age_category,$run,$largest_value,$percentage" >> "$output_csv"

echo "CSV exported to $output_csv"

done
done
