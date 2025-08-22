#!/bin/bash

# Script to concatenate all Swift source files into a single file
# Excludes TestDataGenerator.swift as requested

OUTPUT_FILE="All_Code.swift"
TEMP_FILE="temp_concat.swift"

# Clear the output file
> "$OUTPUT_FILE"

echo "// Generated consolidated code file" > "$OUTPUT_FILE"
echo "// Excludes TestDataGenerator.swift" >> "$OUTPUT_FILE"
echo "// Generated on: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Function to add a file with header
add_file() {
    local file="$1"
    echo "" >> "$OUTPUT_FILE"
    echo "// ==================== $(basename "$file") ====================" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
}

# Add main app files
echo "Adding main app files..."
add_file "PlainWeights/PlainWeightsApp.swift"
add_file "PlainWeights/ContentView.swift"

# Add models
echo "Adding model files..."
add_file "PlainWeights/Models/Exercise.swift"
add_file "PlainWeights/Models/ExerciseSet.swift"

# Add views
echo "Adding view files..."
add_file "PlainWeights/Views/ExerciseListView.swift"
add_file "PlainWeights/Views/AddExerciseView.swift"
add_file "PlainWeights/Views/ExerciseDetailView.swift"

echo "Concatenation complete! Output: $OUTPUT_FILE"
echo "Files included:"
echo "  - PlainWeightsApp.swift"
echo "  - ContentView.swift"
echo "  - Models: Exercise.swift, ExerciseSet.swift"
echo "  - Views: ExerciseListView.swift, AddExerciseView.swift, ExerciseDetailView.swift"
echo "Files excluded:"
echo "  - TestDataGenerator.swift"