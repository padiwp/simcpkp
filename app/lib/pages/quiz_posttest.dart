import 'dart:async';
import 'package:app/pages/result_posttest.dart';
import 'package:app/utils/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

bool isOptionSelected = false;
Set<int> selectedQuestionIndexes = {};

class QuizPostTest extends StatefulWidget {
  const QuizPostTest({
    super.key,
    required this.testId,
    required this.testName,
    required this.testDuration,
    required this.role,
    required this.examinee,
    required this.userId,
    required this.pretestId,
  });

  final String testId;
  final String testName;
  final String testDuration;
  final String role;
  final String examinee;
  final String userId;
  final String pretestId;

  @override
  State<QuizPostTest> createState() => _QuizPostTestState();
}

class _QuizPostTestState extends State<QuizPostTest> {
  late Stream<QuerySnapshot> _questionsStream;
  Map<String, dynamic> selectedOptions = {};
  int currentQuestionIndex = 0;
  Map<String, dynamic> correctAnswer = {};

  late StreamController<int> _timerController;
  late Timer _countdownTimer;
  late int _countdown;

  void _resetValues() {
    isOptionSelected = false;
    currentQuestionIndex = 0;
    selectedOptions.clear();
    selectedQuestionIndexes.clear();
  }

  @override
  void initState() {
    super.initState();
    _resetValues();
    _countdown = 60 * int.parse(widget.testDuration);
    _questionsStream = FirebaseFirestore.instance
        .collection('posttest')
        .doc(widget.testId)
        .collection('questions')
        .snapshots();
    populateCorrectAnswer();
    _timerController = StreamController<int>();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        _countdown--;
        _timerController.add(_countdown);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPostTestPage(
              examinee: widget.examinee,
              userId: widget.userId,
              role: widget.role,
              modulStatus: "modul_unlocked",
              correctAnswer: correctAnswer,
              testId: widget.testId,
              testName: widget.testName,
              selectedOptions: selectedOptions,
              selectedQuestionIndexes: selectedQuestionIndexes.toList(),
              pretestId: widget.pretestId,
            ),
          ),
        );
        timer.cancel();
        setState(() {
          // You can add logic here if needed
        });
      }
    });
  }

  @override
  void dispose() {
    _timerController.close();
    _countdownTimer.cancel();
    super.dispose();
  }

  void populateCorrectAnswer() {
    _questionsStream.listen((snapshot) {
      for (var document in snapshot.docs) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        correctAnswer[data['number']] = data['answer'];
      }
    });
  }

  void goToNextQuestion(AsyncSnapshot<QuerySnapshot> snapshot) {
    setState(() {
      if (currentQuestionIndex < snapshot.data!.docs.length - 1) {
        if (isOptionSelected) {
          selectedQuestionIndexes.add(currentQuestionIndex);
        }
        currentQuestionIndex++;
        isOptionSelected = false;
      } else {
        if (isOptionSelected) {
          selectedQuestionIndexes.add(currentQuestionIndex);
        }
      }
    });
  }

  void goToPreviousQuestion(AsyncSnapshot<QuerySnapshot> snapshot) {
    setState(() {
      if (currentQuestionIndex > 0) {
        currentQuestionIndex--;
        isOptionSelected =
            selectedQuestionIndexes.contains(currentQuestionIndex);
      }
    });
  }

  void _handleCardTap(int index) {
    setState(() {
      currentQuestionIndex = index;
      isOptionSelected = selectedQuestionIndexes.contains(currentQuestionIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Kembalikan false agar tidak membiarkan pengguna kembali
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          title: const Text("Ujian Post Test"),
          actions: [
            StreamBuilder<int>(
              stream: _timerController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int minutes = snapshot.data! ~/ 60;
                  int seconds = snapshot.data! % 60;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('$minutes:$seconds',
                        style: const TextStyle(fontSize: 18)),
                  );
                } else {
                  return Container();
                }
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
            stream: _questionsStream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Text('Ada yang salah');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Memuat...");
              }

              DocumentSnapshot currentQuestion =
                  snapshot.data!.docs[currentQuestionIndex];
              Map<String, dynamic> data =
                  currentQuestion.data()! as Map<String, dynamic>;
              List<dynamic> options = data['option'];

              return Column(
                children: [
                  ScrollableCard(
                    cardItems: List.generate(
                      snapshot.data!.docs.length,
                      (index) => (index + 1).toString(),
                    ),
                    currentIndex: currentQuestionIndex,
                    isOptionSelected: isOptionSelected,
                    onCardTap: _handleCardTap,
                  ),
                  const SizedBox(
                    height: 25,
                    child: Text(
                      "Soal",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      data['question'],
                      textAlign: TextAlign.justify,
                      style: const TextStyle(fontSize: 14),
                    ),
                    // subtitle: Text(data['answer']),
                  ),
                  const SizedBox(
                    height: 25,
                    child: Text(
                      "Pilihan Jawaban",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  // const Divider(),
                  Column(
                    children: options
                        .map(
                          (option) => RadioListTile(
                            title: Container(
                              alignment: Alignment
                                  .centerLeft, // Mengatur perataan teks
                              child: Text(
                                option,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign
                                    .justify, // Menambah properti textAlign
                              ),
                            ),
                            value: option,
                            groupValue: selectedOptions[data['number']],
                            onChanged: (value) {
                              setState(() {
                                selectedOptions[data['number']] = value;
                                isOptionSelected = true;
                                selectedQuestionIndexes.add(
                                  currentQuestionIndex,
                                ); // Menambah index saat ini ke selectedQuestionIndexes
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),

                  const Divider(),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => goToPreviousQuestion(snapshot),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 36)),
                        child: const Text(
                          'Sebelumnya',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 36),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Kirimkan ujian anda"),
                                content: const Text("Apakah kamu yakin?"),
                                actions: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Tutup dialog
                                    },
                                    child: const Text("Batal"),
                                  ),
                                  ElevatedButton(
                                    style: TextButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white),
                                    onPressed: () {
                                      // Reset all values

                                      // Lakukan aksi saat tombol OK ditekan
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ResultPostTestPage(
                                            pretestId: widget.pretestId,
                                            examinee: widget.examinee,
                                            role: widget.role,
                                            userId: widget.userId,
                                            modulStatus: "unlocked",
                                            correctAnswer: correctAnswer,
                                            testId: widget.testId,
                                            testName: widget.testName,
                                            selectedOptions: selectedOptions,
                                            selectedQuestionIndexes:
                                                selectedQuestionIndexes
                                                    .toList(),
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: const Text(
                          'Kirim',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => goToNextQuestion(snapshot),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 36)),
                        child: const Text(
                          'Selanjutnya',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScrollableCard extends StatefulWidget {
  final List<String> cardItems;
  final int currentIndex;
  final bool isOptionSelected;
  final Function(int) onCardTap;

  const ScrollableCard({
    super.key,
    required this.cardItems,
    required this.currentIndex,
    required this.isOptionSelected,
    required this.onCardTap,
  });

  @override
  State<ScrollableCard> createState() => _ScrollableCardState();
}

class _ScrollableCardState extends State<ScrollableCard> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          widget.cardItems.length,
          (index) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                widget.onCardTap(index);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: selectedQuestionIndexes.contains(index)
                      ? Colors.green
                      : index == widget.currentIndex
                          ? widget.isOptionSelected
                              ? Colors.green
                              : Colors.blue
                          : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: TextStyle(
                      color: index == widget.currentIndex
                          ? Colors.white
                          : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
