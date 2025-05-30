import 'harness/app.dart';

void main() {
  final harness = Harness()..install();

  const testFilePath = 'client.html';
  String? originalContent;

  setUpAll(() async {
    final file = File(testFilePath);
    if (file.existsSync()) {
      originalContent = await file.readAsString(); // Backup
    }
  });

  tearDownAll(() async {
    final file = File(testFilePath);
    if (originalContent != null) {
      await file.writeAsString(originalContent!); // Restore original content
    } else if (file.existsSync()) {
      await file.delete(); // Clean up only if it didn't exist originally
    }
  });

  test("GET / serves client.html when file exists", () async {
    // Arrange
    final file = File(testFilePath);
    await file.writeAsString('<html><body>Hello</body></html>');

    // Act
    final response = await harness.agent?.get("/");

    // Assert
    expectResponse(response, 200,
        body: contains('<html><body>Hello</body></html>'));
    expect(response?.headers['content-type']?.first.toLowerCase(),
        startsWith('text/html'));
  });

  test("GET / returns 404 when client.html does not exist", () async {
    // Rename the file temporarily instead of deleting it
    final file = File(testFilePath);
    final tempFile = File('client_backup.html');
    if (file.existsSync()) {
      await file.rename(tempFile.path);
    }

    final response = await harness.agent?.get("/");

    // Assert
    expectResponse(response, 404,
        body: containsPair("error", "File not found"));

    // Restore file
    if (tempFile.existsSync()) {
      await tempFile.rename(file.path);
    }
  });
}
