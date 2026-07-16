import prisma from "../../../infrastructure/database/prisma.js";
import { generateId } from "../../../core/data/store-helpers.js";
import { mockDocuments } from "../../../infrastructure/fallback/mock-data.js";
import { memoryDb } from "../../../infrastructure/fallback/memory-db.js";
import {
  assertMemoryFallbackEnabled,
  shouldUseMemoryFallback,
} from "../../../core/config/data-availability.js";

export const documentStore = {
  async getDocuments(userId?: string) {
    if (!userId) return [];

    const useMem = await shouldUseMemoryFallback();
    if (useMem) {
      const docs = memoryDb.findDocumentsByUserId(userId);
      return docs.length > 0 ? docs : mockDocuments;
    }

    try {
      return await prisma.documentItem.findMany({ where: { userId }, orderBy: { createdAt: "desc" } });
    } catch {
      assertMemoryFallbackEnabled();
      return mockDocuments;
    }
  },

  async createDocument(
    userId: string | undefined,
    title: string,
    description: string,
    icon: string,
    color: string,
  ) {
    if (!userId) throw new Error("Authentication required to create a document");

    const useMem = await shouldUseMemoryFallback();
    if (useMem) {
      return memoryDb.createDocument({ id: generateId("doc"), title, description, icon, color, userId });
    }

    return prisma.documentItem.create({
      data: { id: generateId("doc"), title, description, icon, color, userId },
    });
  },

  async deleteDocument(userId: string | undefined, id: string) {
    if (!userId) return false;

    const useMem = await shouldUseMemoryFallback();
    if (useMem) {
      return memoryDb.deleteDocument(userId, id);
    }

    const result = await prisma.documentItem.deleteMany({ where: { id, userId } });
    return result.count > 0;
  },
};
