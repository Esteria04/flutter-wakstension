function randomIntFromInterval(min, max) { // min and max included 
    return Math.floor(Math.random() * (max - min + 1) + min)
}

setTimeout(() => {
    function imageDownloader() {
        const images = [...document.getElementsByClassName('se-image-resource')];
        images.forEach((image)=>{
            let touchStart;
            image.addEventListener("touchstart", (event) => {
                touchStart = event.timeStamp;
                setTimeout(() => {
                    const touchEnd = event.timeStamp;
                    if (touchEnd - touchStart >= 1000) { // long press duration
                // Perform long press action here
                    alert("Long press!");
                    }
                }, 1000); // Delay in milliseconds
            });
        });
    }

    function outerConcealer() {
        const thumbnails = [...document.getElementsByClassName('thumb')];
        thumbnails.forEach((element)=>element.getElementsByTagName('picture')[0].remove());
        let nicknames = [document.getElementsByClassName('end_user_nick')[0].getElementsByClassName('ellip')[0],...document.getElementsByClassName('reply_to'),...[...document.getElementsByClassName('nick_name')].map((element)=>element.getElementsByClassName('ellip')[0])];
        let nicknameTexts = new Set(nicknames.map((element)=>element.innerHTML));
        nicknameTexts = [...nicknameTexts];

        let counter = 0;
        for (let text of nicknameTexts) {
            for (let nickname of nicknames) {
                if (text==nickname.innerText) {
                    if (nicknameTexts.indexOf(text)==0) {
                        nickname.innerText="[작성자팬치]";
                    }
                    else{nickname.innerText=`[팬치 ${counter}]`;}
                }
            }
            counter+=1;
        }
    }

    function innerConcealer() {
        const thumbnails = [...document.getElementsByClassName('thumb')];
        thumbnails.forEach((element)=>element.getElementsByTagName('picture')[0].remove());
        let nicknames = [...document.getElementsByClassName('nick_name'),...document.getElementsByClassName('reply_to')];
        let nicknameTexts = new Set(nicknames.map((element)=>element.innerText));
        nicknameTexts = [...nicknameTexts];
        let writer = '';
        nicknames.forEach((element)=> element.parentElement.parentElement.getElementsByClassName('writer_tag')[0] ? writer = element.innerText : null);

        let counter = 0;
        for (let text of nicknameTexts) {
            for (let nickname of nicknames) {
                if (text==nickname.innerText) {
                    if (text == writer) {
                        nickname.innerText="[작성자팬치]";
                    }
                    else{nickname.innerText=`[팬치 ${counter+1}]`;}
                }
            }
            counter+=1;
        }
    }

    function pickComment() {
        let nicknames = [...document.getElementsByClassName('nick_name'),...document.getElementsByClassName('reply_to')];
        const pickNumberValue = parseInt(document.getElementById('pick_numbers').value);
        const winnerNums = [];
        let winners = [];
        // picknumvalue -> 만큼 뽑기
        // allowduplicates -> 뽑힌 사람이 겹쳐도 됨
        let counter = 1;
        while (counter <= pickNumberValue) {
            winnerNums.push(randomIntFromInterval(0,nicknames.length-1));
            if (counter === pickNumberValue) {
                winnerNums.forEach(num => {
                    winners.push(nicknames[num]);
                });
                winners = winners.map((winner)=>winner.outerText);
                console.log(winners);
                window.alert(winners);
                break
            }
            counter+=1
        }
    }

    function articleAlert() {
        if (document.getElementsByClassName('CafeMemberArticleItem board_box')[0]==undefined) {
            const articlesList = document.getElementsByClassName('list_area')[0];
            const articles = articlesList.getElementsByClassName('board_box');
            const alertElement = document.createElement('li');
            alertElement.className='board_box';
            alertElement.id='safeline';
            const alertText = document.createElement("span");
            alertText.innerText = "15 SAFE LINE";
            alertElement.appendChild(alertText);
            alertElement.style.backgroundColor = '#a4b15f95';
            alertElement.style.textAlign = 'center';
            alertElement.style.color = '#FFFFFF';
            alertElement.style.marginTop = '5px';
            alertElement.style.marginBottom = '5px';
            alertElement.style.height = '35px';
            alertElement.style.display = "flex";
            alertElement.style.justifyContent = "center";
            alertElement.style.alignItems = "center";

            if (document.getElementById("safeline")) {
                articles[16].remove();
                articlesList.insertBefore(alertElement, articles[16]);
            } else {
                articlesList.insertBefore(alertElement, articles[16]);
            }
        }
    }

    function addNickConcealer() {
        try {
            const userWrap = document.querySelector("#ct > div.post_title > div.user_wrap");
            const outerConcealerBtn = document.createElement('button');
            outerConcealerBtn.className='btn_subscribe nick_outerConcealerBtn';
            outerConcealerBtn.innerHTML = '익명화';
            outerConcealerBtn.style.marginRight = '80px';
            outerConcealerBtn.onclick = outerConcealer;
            document.getElementsByClassName('nick_outerConcealerBtn')[0]!=undefined ? null : userWrap.appendChild(outerConcealerBtn);
       } catch{}
       try {
           const innerConcealerBtn = document.createElement('button');
           innerConcealerBtn.className = 'btn_sort nick_innerConcealerBtn';
           innerConcealerBtn.innerHTML = '익명화';
           innerConcealerBtn.onclick = innerConcealer;
           
           const btnArea = document.getElementsByClassName('sort_area')[0];
           if (document.getElementsByClassName('btn_sort on')[0]) {
               document.getElementsByClassName('nick_innerConcealerBtn')[0]!=undefined ? null : btnArea.appendChild(innerConcealerBtn);
           }
       } catch{}
    }

    function addCommentPicker() {
        // create the dialog element
        const dialog = document.createElement("dialog");
        dialog.id = "comment_picker_dialog";

        // create the form element
        const form = document.createElement("form");
        form.style.display = "flex";
        form.style.flexDirection = "column";
        form.method = "dialog";

        // create the input element for number of winners
        const numberOfWinnersInput = document.createElement("input");
        numberOfWinnersInput.type = "number";
        numberOfWinnersInput.style.width = "80px";
        numberOfWinnersInput.min = "1";
        numberOfWinnersInput.max = `${document.getElementsByClassName('main_title')[0].innerText.substring(3)}`;
        numberOfWinnersInput.id = "pick_numbers";
        numberOfWinnersInput.placeholder = "추첨인원";

        // create the button element for picking winners
        const pickButton = document.createElement("button");
        pickButton.className = "pick_button";
        pickButton.textContent = "추첨하기";
        pickButton.onclick = pickComment;

        // append all the elements to the form
        form.appendChild(numberOfWinnersInput);
        form.appendChild(document.createElement("br"));
        form.appendChild(pickButton);

        // append the form to the dialog
        dialog.appendChild(form);
        const pickerButton = document.createElement('button');
        pickerButton.className = 'btn_sort commentPicker'
        pickerButton.innerText = '댓글 추첨'
        pickerButton.addEventListener('click',()=>{
            dialog.showModal();
        });
        const btnArea = document.getElementsByClassName('sort_area')[0];
        if (document.getElementsByClassName('btn_sort on')[0]) {
            document.getElementsByClassName('pick_btn')[0]!=undefined ? null : btnArea.appendChild(pickerButton);
            document.body.appendChild(dialog);
        }
    }

    function cafeEtcRemover() {
        try {
            document.getElementsByClassName("gnb_l")[0].style.opacity = '0';//cafe
            document.getElementsByClassName("gnb_home")[0].style.pointerEvents = 'none';//cafe
        }
        catch(e){}
        try {
            document.getElementsByClassName("gnd_app")[0].remove(); //앱 열기
        } catch (e) {}
        try {
            document.getElementsByClassName('go_app_bottom')[0].remove(); //카페앱 광고
        } catch (e) {}
        try {
            document.getElementsByTagName('footer')[0].remove(); //footer
        } catch (e) {}
        try {
            document.getElementsByClassName('go_app')[0].remove(); //앱 열기
        } catch (e) {}
    }
    cafeEtcRemover();
    try {
        articleAlert();
    } catch (error) {}
    try {
        addNickConcealer();
    } catch (error) {}
    try {
        imageDownloader();
    } catch (error) {}
    try {
        addCommentPicker();
    } catch (error) {}
}, 2000);
