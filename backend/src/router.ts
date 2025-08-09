
import { Router } from 'express';
import prisma from './client';

const router = Router();

// Routes pour les Protocoles
router.get('/protocols', async (req, res) => {
  const protocols = await prisma.protocol.findMany({
    include: { exercises: { include: { exercise: true } } },
  });

  const protocolsWithDaysAsArray = protocols.map(protocol => ({
    ...protocol,
    exercises: protocol.exercises.map(ex => ({
      ...ex,
      days: ex.days.split(',').filter(d => d),
    })),
  }));

  res.json(protocolsWithDaysAsArray);
});

router.post('/protocols', async (req, res) => {
  const { name, exercises } = req.body;
  const protocol = await prisma.protocol.create({
    data: {
      name,
      exercises: {
        create: exercises?.map((ex: any) => ({
          repetitions: ex.repetitions,
          series: ex.series,
          pause: ex.pause,
          tempo: ex.tempo,
          notes: ex.notes,
          days: ex.days.join(','),
          exercise: { connect: { id: ex.exerciseId } },
        })) ?? [],
      },
    },
    include: { exercises: true },
  });
  res.status(201).json(protocol);
});

// Routes pour les Exercices dans un Protocole
router.post('/protocols/:protocolId/exercises', async (req, res) => {
  const { protocolId } = req.params;
  const { days, ...rest } = req.body;
  const newExercise = await prisma.protocolExercise.create({
    data: {
      ...rest,
      days: days.join(','),
      protocolId: parseInt(protocolId),
    },
  });
  res.status(201).json(newExercise);
});

router.delete('/protocol-exercises/:id', async (req, res) => {
  const { id } = req.params;
  await prisma.protocolExercise.delete({ where: { id: parseInt(id) } });
  res.status(204).send();
});

// Route pour lister les exercices de base
router.get('/exercises', async (req, res) => {
  const exercises = await prisma.exercise.findMany();
  res.json(exercises.map(ex => ({
    ...ex,
    articulation: ex.articulation?.split(',').filter(a => a) ?? [],
    muscles: ex.muscles?.split(',').filter(m => m) ?? [],
  })));
});

router.post('/exercises', async (req, res) => {
  const { name, articulation, muscles } = req.body;
  try {
    const exercise = await prisma.exercise.create({
      data: {
        name,
        articulation: articulation?.join(','),
        muscles: muscles?.join(','),
      },
    });
    res.status(201).json({
      ...exercise,
      articulation: exercise.articulation?.split(',').filter(a => a) ?? [],
      muscles: exercise.muscles?.split(',').filter(m => m) ?? [],
    });
  } catch (e) {
    res.status(400).json({ error: 'Exercise with this name already exists' });
  }
});

router.put('/exercises/:id', async (req, res) => {
  const { id } = req.params;
  const { name, articulation, muscles } = req.body;
  try {
    const updatedExercise = await prisma.exercise.update({
      where: { id: parseInt(id) },
      data: {
        name,
        articulation: articulation?.join(','),
        muscles: muscles?.join(','),
      },
    });
    res.status(200).json({
      ...updatedExercise,
      articulation: updatedExercise.articulation?.split(',').filter(a => a) ?? [],
      muscles: updatedExercise.muscles?.split(',').filter(m => m) ?? [],
    });
  } catch (e) {
    res.status(400).json({ error: 'Failed to update exercise' });
  }
});

export default router;
