/* CIVILINE quiz engine — renders MCQ data into interactive question cards */
(function(){
  function letter(i){ return String.fromCharCode(65+i); }

  function renderQuiz(containerId, questions){
    var container = document.getElementById(containerId);
    if(!container) return;

    var state = questions.map(function(){ return null; });

    var progressWrap = document.createElement('div');
    progressWrap.className = 'quiz-progress';
    progressWrap.innerHTML =
      '<span class="mono">ANSWERED <span id="qz-answered">0</span>/' + questions.length + '</span>' +
      '<div class="progress-track"><div class="progress-fill" id="qz-progress"></div></div>' +
      '<span class="mono" id="qz-score">SCORE 0</span>';
    container.appendChild(progressWrap);

    questions.forEach(function(q, qi){
      var card = document.createElement('div');
      card.className = 'question-card';

      var numEl = document.createElement('div');
      numEl.className = 'qnum mono';
      numEl.textContent = 'QUESTION ' + (qi+1) + ' / ' + questions.length;
      card.appendChild(numEl);

      var textEl = document.createElement('div');
      textEl.className = 'qtext';
      textEl.textContent = q.q;
      card.appendChild(textEl);

      var optsEl = document.createElement('div');
      optsEl.className = 'options';

      var explEl = document.createElement('div');
      explEl.className = 'explanation';
      explEl.textContent = q.explanation;

      q.options.forEach(function(opt, oi){
        var optEl = document.createElement('div');
        optEl.className = 'option';
        optEl.innerHTML = '<span class="letter mono">' + letter(oi) + '</span><span>' + opt + '</span>';
        optEl.addEventListener('click', function(){
          if(state[qi] !== null) return; // lock after first answer
          state[qi] = oi;
          var allOpts = optsEl.querySelectorAll('.option');
          allOpts.forEach(function(el, idx){
            el.classList.add('selected');
            if(idx === q.answer){ el.classList.add('correct'); }
            else if(idx === oi){ el.classList.add('incorrect'); }
          });
          explEl.classList.add('show');
          updateProgress();
        });
        optsEl.appendChild(optEl);
      });

      card.appendChild(optsEl);
      card.appendChild(explEl);
      container.appendChild(card);
    });

    function updateProgress(){
      var answered = state.filter(function(s){ return s !== null; }).length;
      var score = state.reduce(function(acc, s, i){
        return acc + (s === questions[i].answer ? 1 : 0);
      }, 0);
      document.getElementById('qz-answered').textContent = answered;
      document.getElementById('qz-score').textContent = 'SCORE ' + score + '/' + questions.length;
      document.getElementById('qz-progress').style.width = (answered/questions.length*100) + '%';
    }
  }

  window.CIVILINE = { renderQuiz: renderQuiz };
})();
