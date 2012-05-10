SELECT DB_NAME(database_id) AS DatabaseName,
Name AS Logical_File_Name,
Physical_Name, (size*8)/1024 SizeMB, size, max_size, growth
FROM sys.master_files
WHERE max_size > 0;
