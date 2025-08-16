-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_ProtocolExercise" (
    "id" INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    "protocolId" INTEGER NOT NULL,
    "exerciseId" INTEGER NOT NULL,
    "repetitions" INTEGER NOT NULL,
    "series" INTEGER NOT NULL,
    "pause" INTEGER NOT NULL,
    "tempo" TEXT NOT NULL,
    "notes" TEXT,
    "days" TEXT NOT NULL DEFAULT '',
    CONSTRAINT "ProtocolExercise_protocolId_fkey" FOREIGN KEY ("protocolId") REFERENCES "Protocol" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "ProtocolExercise_exerciseId_fkey" FOREIGN KEY ("exerciseId") REFERENCES "Exercise" ("id") ON DELETE CASCADE ON UPDATE CASCADE
);
INSERT INTO "new_ProtocolExercise" ("days", "exerciseId", "id", "notes", "pause", "protocolId", "repetitions", "series", "tempo") SELECT "days", "exerciseId", "id", "notes", "pause", "protocolId", "repetitions", "series", "tempo" FROM "ProtocolExercise";
DROP TABLE "ProtocolExercise";
ALTER TABLE "new_ProtocolExercise" RENAME TO "ProtocolExercise";
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;
