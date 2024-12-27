/*
  Warnings:

  - You are about to drop the column `delete` on the `Todo` table. All the data in the column will be lost.
  - You are about to drop the column `done` on the `Todo` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE `Todo` DROP COLUMN `delete`,
    DROP COLUMN `done`,
    ADD COLUMN `delete_flag` BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN `done_flag` BOOLEAN NOT NULL DEFAULT false;
