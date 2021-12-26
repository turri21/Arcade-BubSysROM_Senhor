#include <iostream>
#include <fstream>




int main()
{
	std::ifstream MemDump("gx400.bin", std::ios::in | std::ios::binary);

	char inBuffer;
	unsigned char outBuffer[4] = "0  "; // 0(space)

	////////////////////////////
	////////	charram
	////

	char init_charram_filename[21] = "init_charram_px0.txt";
	std::ofstream charram_px[8];
	for (int i = 0; i < 8; i++) {
		charram_px[i].open(init_charram_filename, std::ios::out);
		init_charram_filename[15]++;
	}

	MemDump.seekg(0x30000, std::ios::beg);

	for (int i = 0; i < 0x4000; i++) { //0x4000 times
		for (int j = 0; j < 4; j++) {
			MemDump.read((char*)&inBuffer, 1);

			outBuffer[0] = inBuffer;
			outBuffer[0] = outBuffer[0] >> 0x4;
			(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);
			charram_px[j * 2].write((char*)outBuffer, 2);

			outBuffer[0] = inBuffer;
			outBuffer[0] = outBuffer[0] & 0x0F;
			(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);
			charram_px[(j * 2) + 1].write((char*)outBuffer, 2);
		}
	}

	for (int i = 0; i < 8; i++) {
		charram_px[i].close();
	}



	////////////////////////////
	////////	scrollram
	////

	std::ofstream scrollram("init_scrollram.txt", std::ios::out);

	MemDump.seekg(0x50000, std::ios::beg);

	for (int i = 0; i < 0x800; i++) { //0x800 times
		MemDump.read((char*)&inBuffer, 1);
		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		scrollram.write((char*)outBuffer, 3);
	}

	scrollram.close();



	////////////////////////////
	////////	vram1
	////

	std::ofstream vram1_high("init_vram1_high.txt", std::ios::out);
	std::ofstream vram1_low("init_vram1_low.txt", std::ios::out);

	MemDump.seekg(0x52000, std::ios::beg);

	for (int i = 0; i < 0x1000; i++) { //0x1000 times
		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		vram1_high.write((char*)outBuffer, 3);


		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		vram1_low.write((char*)outBuffer, 3);
	}

	vram1_high.close();
	vram1_low.close();



	////////////////////////////
	////////	vram2
	////

	std::ofstream vram2("init_vram2.txt", std::ios::out);

	MemDump.seekg(0x54000, std::ios::beg);

	for (int i = 0; i < 0x1000; i++) { //0x1000 times
		MemDump.read((char*)&inBuffer, 1);
		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		vram2.write((char*)outBuffer, 3);
	}

	vram2.close();



	////////////////////////////
	////////	objram
	////

	std::ofstream objram("init_objram.txt", std::ios::out);

	MemDump.seekg(0x56000, std::ios::beg);

	for (int i = 0; i < 0x800; i++) { //0x800 times
		MemDump.read((char*)&inBuffer, 1);
		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		objram.write((char*)outBuffer, 3);
	}

	objram.close();



	////////////////////////////
	////////	colorram
	////

	std::ofstream colorram_high("init_colorram_high.txt", std::ios::out);
	std::ofstream colorram_low("init_colorram_low.txt", std::ios::out);

	MemDump.seekg(0x5A000, std::ios::beg);

	for (int i = 0; i < 0x800; i++) { //0x800 times
		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		colorram_high.write((char*)outBuffer, 3);


		MemDump.read((char*)&inBuffer, 1);

		outBuffer[0] = inBuffer;
		outBuffer[0] = outBuffer[0] >> 0x4;
		(outBuffer[0] > 0x9) ? (outBuffer[0] = outBuffer[0] + 0x37) : (outBuffer[0] = outBuffer[0] + 0x30);

		outBuffer[1] = inBuffer;
		outBuffer[1] = outBuffer[1] & 0x0F;
		(outBuffer[1] > 0x9) ? (outBuffer[1] = outBuffer[1] + 0x37) : (outBuffer[1] = outBuffer[1] + 0x30);
		colorram_low.write((char*)outBuffer, 3);
	}

	colorram_high.close();
	colorram_low.close();


	return 0;
}

