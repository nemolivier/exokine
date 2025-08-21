
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
  const { name, remarks, exercises } = req.body;
  const createdProtocol = await prisma.protocol.create({
    data: {
      name,
      remarks, // Add remarks to the creation data
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
    include: { exercises: { include: { exercise: true } } },
  });

  // Transform the exercises in the response to have days as an array
  const responseProtocol = {
    ...createdProtocol,
    exercises: createdProtocol.exercises.map(ex => ({
      ...ex,
      days: ex.days.split(',').filter(d => d),
    })),
  };

  res.status(201).json(responseProtocol);
});

router.delete('/protocols/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await prisma.protocol.delete({
      where: { id: parseInt(id) },
    });
    res.status(204).send();
  } catch (error) {
    // Handle potential errors, e.g., protocol not found
    res.status(404).json({ error: "Protocol not found." });
  }
});

router.put('/protocols/:id', async (req, res) => {
  const { id } = req.params;
  const { name, remarks, exercises } = req.body;

  try {
    const updatedProtocol = await prisma.$transaction(async (prisma) => {
      await prisma.protocolExercise.deleteMany({
        where: { protocolId: parseInt(id) },
      });

      const protocol = await prisma.protocol.update({
        where: { id: parseInt(id) },
        data: {
          remarks,
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
        include: { exercises: { include: { exercise: true } } },
      });

      return protocol;
    });

    console.log('DEBUG: Updated Protocol from DB:', updatedProtocol); // Debug log

    const responseProtocol = {
      ...updatedProtocol,
      exercises: updatedProtocol.exercises.map(ex => ({
        ...ex,
        days: ex.days.split(',').filter(d => d),
      })),
    };

    res.status(200).json(responseProtocol);
  } catch (error) {
    res.status(404).json({ error: "Failed to update protocol. Protocol not found." });
  }
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
  const { name, articulation, muscles, type } = req.body;
  try {
    const exercise = await prisma.exercise.create({
      data: {
        name,
        articulation: articulation?.join(','),
        muscles: muscles?.join(','),
        type,
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
  const { name, articulation, muscles, type } = req.body;
  try {
    const updatedExercise = await prisma.exercise.update({
      where: { id: parseInt(id) },
      data: {
        name,
        articulation: articulation?.join(','),
        muscles: muscles?.join(','),
        type,
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

router.delete('/exercises/:id', async (req, res) => {
  const { id } = req.params;
  try {
    await prisma.exercise.delete({
      where: { id: parseInt(id) },
    });
    res.status(204).send();
  } catch (error) {
    res.status(404).json({ error: "Exercise not found." });
  }
});

export default router;
