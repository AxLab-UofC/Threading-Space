void set_new_table() {
  battery_table.addColumn("Time");
  for (int i = 0; i < nCubes; i++) {
    battery_table.addColumn("Cube " + cubes[i].id);
  }
  //update_table();
}

void update_table() {
  TableRow newRow = battery_table.addRow(); // Create a new row
  
  String curr_time = nf(hour(), 2) + ":" + nf(minute(), 2);
  newRow.setString("Time", curr_time); // Store current time
  
  for (int i = 0; i < nCubes; i++) {
    newRow.setInt("Cube " + cubes[i].id, cubes[i].battery); // Store battery levels
  }

  saveData(); // Save the updated table
}

void saveData() {
  saveTable(battery_table, folderPath + file_name);
  println("Updated: " + file_name);
}

String getLatestTableFilename() {
  String dateStr = year() + nf(month(), 2) + nf(day(), 2); // Format: YYYYMMDD
  String baseName = "battery_report_" + dateStr;
  String extension = ".csv";

  int fileNumber = 0;
  String latestFile = baseName + extension;

  // Find the first non-existing file
  while (new File(folderPath + latestFile).exists()) {
    fileNumber++;
    latestFile = baseName + "_" + fileNumber + extension;
  }
  
  println(folderPath + latestFile);
  return latestFile;
}
