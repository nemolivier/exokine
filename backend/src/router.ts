import { Router } from 'express';
// import prisma from './client'; // Décommenter quand la DB sera prête

const router = Router();

// Routes pour les Protocoles
router.get('/protocols', async (req, res) => {
  // const protocols = await prisma.protocol.findMany();
  res.json([{ id: 1, name: 'Protocole Haut du corps', exercises: [] }]); // Données factices
});

router.post('/protocols', async (req, res) => {
  // const protocol = await prisma.protocol.create({ data: req.body });
  res.status(201).json({ id: 2, ...req.body }); // Données factices
});

// Routes pour les Exercices dans un Protocole
router.post('/protocols/:protocolId/exercises', async (req, res) => {
  // const { protocolId } = req.params;
  // const newExercise = await prisma.protocolExercise.create({ data: { ...req.body, protocolId: parseInt(protocolId) } });
  res.status(201).json({ id: 1, ...req.body }); // Données factices
});

router.delete('/protocol-exercises/:id', async (req, res) => {
  // const { id } = req.params;
  // await prisma.protocolExercise.delete({ where: { id: parseInt(id) } });
  res.status(204).send();
});

// Route pour lister les exercices de base
router.get('/exercises', async (req, res) => {
  // const exercises = await prisma.exercise.findMany();
  res.json([ // Données factices
    { id: 1, name: 'Pompes' },
    { id: 2, name: 'Tractions' },
    { id: 3, name: 'Squats' },
  ]);
});

export default router;
