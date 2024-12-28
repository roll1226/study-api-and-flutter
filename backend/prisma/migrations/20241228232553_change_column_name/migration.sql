/*
  Warnings:

  - You are about to drop the column `delete_flag` on the `Todo` table. All the data in the column will be lost.
  - You are about to drop the column `done_flag` on the `Todo` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE `Todo` DROP COLUMN `delete_flag`,
    DROP COLUMN `done_flag`,
    ADD COLUMN `deleteFlag` BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN `doneFlag` BOOLEAN NOT NULL DEFAULT false;
